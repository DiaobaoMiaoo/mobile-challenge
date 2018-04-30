//
//  PhotoModel.swift
//  CodeChallenge
//
//  Created by Ke MA on 2018-04-29.
//  Copyright © 2018 kemin. All rights reserved.
//

import Foundation
import SwiftyJSON

class PhotoModel {
    
    let id: Int
    let imageUrl: String
    let width: Float
    let height: Float
    let index: Int
    
    var name: String?
    var description: String?
    var userName: String?
    var userAvatarUrl: String?
    
    init(id: Int, imageUrl: String, width: Float, height: Float, index: Int) {
        self.id = id
        self.imageUrl = imageUrl
        self.width = width
        self.height = height
        self.index = index
    }
    
    static func getPhotoModelFrom(_ rawData: JSON, withIndex index: Int) -> PhotoModel? {
        guard let id = rawData["id"].int,
            let imageUrls = rawData["image_url"].array,
            let imageUrl = imageUrls.first?.string,
            let width = rawData["width"].float,
            let height = rawData["height"].float else { return nil }
        
        let photo = PhotoModel(id: id, imageUrl: imageUrl, width: width, height: height, index: index)
        photo.name = rawData["name"].string
        photo.description = rawData["description"].string
        photo.userName = rawData["user"]["username"].string
        photo.userAvatarUrl = rawData["user"]["avatars"]["default"]["https"].string
        return photo
    }
}
