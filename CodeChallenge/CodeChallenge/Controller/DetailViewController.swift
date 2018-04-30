//
//  DetailViewController.swift
//  CodeChallenge
//
//  Created by Ke MA on 2018-04-29.
//  Copyright © 2018 kemin. All rights reserved.
//

import UIKit
import SDWebImage

let browserCellIdentifier = "PhotoBrowserCell"

protocol DetailViewDelegate: class {
    func numberOfPhotos() -> Int
    func photoAtIndexPath(_ indexPath: IndexPath) -> PhotoModel
    func scrollToIndexPath(_ indexPath: IndexPath)
    func loadMorePhotos(completion: @escaping (ResponseStatus, [PhotoModel]) -> Void)
    func indexPathsForPhotos(_ photos: [PhotoModel]) -> [IndexPath]
    func orientationChanged()
}

class DetailViewController: UIViewController {
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var photoBrowser: UICollectionView!
    @IBOutlet weak var indexLabel: UILabel! // View for debugging
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var photoDescriptionLabel: UILabel!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var currentIndexPath: IndexPath!
    var nextIndexPath: IndexPath!
    var viewDidLayoutSubviewsForTheFirstTime = true
    weak var delegate: DetailViewDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        userAvatarImageView.layer.cornerRadius = 10
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if viewDidLayoutSubviewsForTheFirstTime {
            viewDidLayoutSubviewsForTheFirstTime = false
            let _ = photoBrowser.collectionViewLayout.collectionViewContentSize
            photoBrowser.scrollToItem(at: currentIndexPath, at: .centeredHorizontally, animated: false)
            updateDetailsInfoForPhoto(delegate.photoAtIndexPath(currentIndexPath))
        }
    }
    
    func updateDetailsInfoForPhoto(_ photo: PhotoModel) {
        indexLabel.isHidden = !isDebugging
        indexLabel.text = "\(photo.index)"
        photoTitleLabel.text = photo.name
        photoDescriptionLabel.text = photo.description
        userNameLabel.text = photo.userName
        if let avatarUrlString = photo.userAvatarUrl, let avatarUrl = URL(string: avatarUrlString) {
            userAvatarImageView.sd_setImage(with: avatarUrl, completed: nil)
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        photoBrowser.collectionViewLayout.invalidateLayout()
        DispatchQueue.main.async {
            self.photoBrowser.scrollToItem(at: self.currentIndexPath, at: .centeredHorizontally, animated: false)
            self.updateDetailsInfoForPhoto(self.delegate.photoAtIndexPath(self.currentIndexPath))
        }
        delegate.orientationChanged()
    }
}

extension DetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate!.numberOfPhotos()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: browserCellIdentifier, for: indexPath) as! PhotoBrowserCell
        if let url = URL(string: delegate.photoAtIndexPath(indexPath).imageUrl) {
            cell.photoImageView.sd_setImage(with: url, completed: nil)
        }
        if indexPath.item == (delegate.numberOfPhotos() - 2) {
            delegate.loadMorePhotos { status, photos in
                switch status {
                case .success:
                    guard photos.count > 0 else { return }
                    self.photoBrowser.insertItems(at: self.delegate.indexPathsForPhotos(photos))
                case .failure(let error):
                    print(error)
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height = collectionView.bounds.height
        return CGSize(width: width, height: height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visiblePath = photoBrowser.indexPathsForVisibleItems[0]
        currentIndexPath = visiblePath
        delegate.scrollToIndexPath(visiblePath)
        updateDetailsInfoForPhoto(delegate.photoAtIndexPath(visiblePath))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        updateDetailsInfoForPhoto(delegate.photoAtIndexPath(indexPath))
    }
}
