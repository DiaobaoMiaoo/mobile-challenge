//
//  CollectionViewCell.swift
//  CodeChallenge
//
//  Created by Ke MA on 2018-04-29.
//  Copyright © 2018 kemin. All rights reserved.
//

import UIKit
import SDWebImage

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoIndex: UILabel! // View For Debugging
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoImageHeightConstraint: NSLayoutConstraint!
    
    var photo: PhotoModel? {
        didSet {
            guard let photo = photo else { return }
            guard let imageURL = URL(string: photo.imageUrl) else { return }
            self.photoIndex.isHidden = !isDebugging
            self.photoIndex.text = "\(photo.index)"
            self.photoImageView.sd_setImage(with: imageURL, completed: nil)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoIndex.text = nil
        photoImageView.image = nil
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        let attributes = layoutAttributes as! LayoutAttributes
        photoImageHeightConstraint.constant = attributes.imageHeight
    }
}
