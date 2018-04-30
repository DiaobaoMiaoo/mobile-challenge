//
//  CollectionViewLayout.swift
//  CodeChallenge
//
//  Created by Ke MA on 2018-04-29.
//  Copyright © 2018 kemin. All rights reserved.
//

import UIKit

protocol LayoutDelegate: class {
    
    func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat
}

class LayoutAttributes: UICollectionViewLayoutAttributes {

    var imageHeight: CGFloat = 0
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! LayoutAttributes
        copy.imageHeight = imageHeight
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? LayoutAttributes {
            if attributes.imageHeight == imageHeight {
                return super.isEqual(object)
            }
        }
        return false
    }
}

class CollectionViewLayout: UICollectionViewLayout {
    
    weak var delegate: LayoutDelegate!
    var numberOfColumns = 0
    var cellPadding: CGFloat = 0
    
    var column = 0
    var xOffSets = [CGFloat]()
    var yOffsets = [CGFloat]()
    var cache = [LayoutAttributes]()
    
    fileprivate var contentHeight: CGFloat = 0
    fileprivate var width: CGFloat {
        let insets = collectionView!.contentInset
        return collectionView!.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: width, height: contentHeight)
    }
    
    override class var layoutAttributesClass : AnyClass {
        return LayoutAttributes.self
    }
    
    override func prepare() {
        
        let columnWidth = width / CGFloat(numberOfColumns)
        
        if xOffSets.isEmpty {
            for column in 0 ..< numberOfColumns {
                xOffSets.append(CGFloat(column) * columnWidth)
            }
        }
        
        if yOffsets.isEmpty {
            yOffsets = [CGFloat](repeating: 0, count: numberOfColumns)
        }
        
        for item in cache.count ..< collectionView!.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let width = columnWidth - (cellPadding * 2)
            let imageHeight = delegate.collectionView(collectionView!, heightForImageAtIndexPath: indexPath, withWidth: width)
            let height = cellPadding + imageHeight + cellPadding
            
            let frame = CGRect(x: xOffSets[column], y: yOffsets[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            let attributes = LayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            attributes.imageHeight = imageHeight
            cache.append(attributes)
            contentHeight = max(contentHeight, frame.maxY)
            yOffsets[column] = yOffsets[column] + height
            
            if let minY = yOffsets.min(), let nextColumn = yOffsets.index(of: minY) {
                column = nextColumn
            } else {
                column = column >= (numberOfColumns - 1) ? 0 : column + 1
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.item < cache.count else { return nil }
        return cache[indexPath.item]
    }
}
