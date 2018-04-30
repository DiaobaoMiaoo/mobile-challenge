//
//  PhotoManager.swift
//  CodeChallenge
//
//  Created by Ke MA on 2018-04-29.
//  Copyright © 2018 kemin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum ResponseStatus {
    case success
    case failure(String)
}

class PhotoManager {
    
    private let consumerKey = "4CYZqPjc8VsCKLr8MSRUANbT4RVAvVuCLMLZGimW"
    
    var photos = [PhotoModel]()
    var currentPage: Int = 0
    var currentPhotoIndex: Int =  0
    
    var numberOfPhotos: Int {
        return photos.count
    }
    
    func photoAtIndexPath(_ indexPath: IndexPath) -> PhotoModel {
        return photos[indexPath.item]
    }
    
    func heightForPhotoAtIndexPath(_ indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let photo = photoAtIndexPath(indexPath)
        return width * CGFloat(photo.height / photo.width)
    }
    
    func indexPathsForPhotos(_ photos: [PhotoModel]) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        for photo in photos {
            indexPaths.append(IndexPath(item: photo.index, section: 0))
        }
        return indexPaths
    }
    
    func loadPhotos(completion: @escaping (ResponseStatus, [PhotoModel]) -> Void) {
        let params: [String: String] = ["consumer_key": "4CYZqPjc8VsCKLr8MSRUANbT4RVAvVuCLMLZGimW",
                                        "feature": "popular",
                                        "image_size": "2048",
                                        "page": "\(currentPage + 1)"]
        
        Alamofire.request("https://api.500px.com/v1/photos?", parameters: params).responseJSON { response in
            switch response.result {
                
            case .success(let value):
                let json = JSON(value)
                guard response.requestSucceed(),
                    let photoJsonArray = json["photos"].array,
                    let currentPage = json["current_page"].int else {
                    completion(ResponseStatus.failure("Something went wrong."), [])
                    return
                }
                
                var loadedPhotos = [PhotoModel]()
                for photoJson in photoJsonArray {
                    if let photo = PhotoModel.getPhotoModelFrom(photoJson, withIndex: self.currentPhotoIndex) {
                        loadedPhotos.append(photo)
                        let newIndex = self.currentPhotoIndex + 1
                        self.currentPhotoIndex = newIndex
                    }
                }
                self.photos += loadedPhotos
                self.currentPage = currentPage
                completion(ResponseStatus.success, loadedPhotos)
                
            case .failure(let error):
                completion(ResponseStatus.failure(error.localizedDescription), [])
            }
        }
    }
}

extension DataResponse {
    
    // Check the networking request is successful with a status code 200.
    func requestSucceed() -> Bool {
        if let statusCode = self.response?.statusCode, statusCode.requestIsSuccess() {
            return true
        }
        return false
    }
}

extension Int {
    
    // Check if the response status code is valid
    func requestIsSuccess() -> Bool {
        return (self >= 200 && self < 300)
    }
}
