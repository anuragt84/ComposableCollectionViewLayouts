//
//  ComposableCollectionViewLayouts.swift
//  CollectionViewTest
//
//  Created by Anurag Tolety on 11/12/16.
//  Copyright © 2016 Cow Corner Software. All rights reserved.
//

import Foundation
import UIKit

protocol ComposableLayoutProvider {
    /// Prepare the layout process
    ///
    /// - Returns:
    func prepare()
    /// Should adjust the passed in attributes according to the effect desired
    ///
    /// - Parameters:
    ///   - attributes: Collection view layout attributes to be adjusted
    ///   - collectionView: Collection View for which the attributes are being adjusted
    ///   - indexPath: Index path for the attributes
    /// - Returns:
    func adjustItemAttributes(attributes: UICollectionViewLayoutAttributes,
                              forCollectionView collectionView: UICollectionView,
                              atIndexPath indexPath: IndexPath)
    /// Returns true if the layout should be invalidated
    ///
    /// - Parameter newBounds: The changed bounds
    /// - Returns: See description
    func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
}

/// Represents a layout that can be composed from a list of layout providers that implement the `ComposableLayoutProvider`
/// protocol
class ComposedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var layoutProviders = [ComposableLayoutProvider]()
    var attributesList = [IndexPath: UICollectionViewLayoutAttributes]()
    
    init(layoutProviders: [ComposableLayoutProvider]) {
        self.layoutProviders = layoutProviders
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return layoutProviders.reduce(true, { (result, layout) -> Bool in
            return result && layout.shouldInvalidateLayout(forBoundsChange: newBounds)
        })
    }
    
    open override func prepare() {
        super.prepare()
        
        for layoutProvider in layoutProviders {
            layoutProvider.prepare()
        }
        
        guard let collectionView = collectionView else { return }
        
        attributesList.removeAll(keepingCapacity: true)
        for section in 0..<collectionView.numberOfSections {
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)
                let attributes = layoutAttributesForItem(at: indexPath)!.copy() as! UICollectionViewLayoutAttributes
                for layoutProvider in layoutProviders {
                    layoutProvider.adjustItemAttributes(attributes: attributes,
                                                        forCollectionView: collectionView,
                                                        atIndexPath: indexPath)
                }
                attributesList[indexPath] = attributes
            }
        }
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesList.values.filter({ (attributes) -> Bool in
            attributes.frame.intersects(rect)
        })
    }
    
}

struct FirstCellFadingLayoutProvider: ComposableLayoutProvider {
    
    func prepare() {
        
    }
    
    func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    func adjustItemAttributes(attributes: UICollectionViewLayoutAttributes,
                              forCollectionView collectionView: UICollectionView,
                              atIndexPath indexPath: IndexPath) {
        let cellOffsetY = CGFloat(indexPath.item) * Constants.ColorCellHeight
        var alpha = CGFloat(1.0)
        let contentOffsetY = collectionView.contentOffset.y
        let offsetDiff = contentOffsetY - cellOffsetY
        if offsetDiff > 0 && offsetDiff < Constants.ColorCellHeight {
            alpha = 1.0 - offsetDiff / Constants.ColorCellHeight
        }
        attributes.alpha = alpha
        attributes.zIndex = indexPath.item
    }
    
}

struct FirstCellShrinkingLayoutProvider: ComposableLayoutProvider {
    
    func prepare() {
        
    }
    
    func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    func adjustItemAttributes(attributes: UICollectionViewLayoutAttributes,
                              forCollectionView collectionView: UICollectionView,
                              atIndexPath indexPath: IndexPath) {
        var cellOffsetY = CGFloat(indexPath.item) * Constants.ColorCellHeight
        var shrinkingPercent = CGFloat(0)
        let contentOffsetY = collectionView.contentOffset.y
        let offsetDiff = contentOffsetY - cellOffsetY
        if offsetDiff > 0 && offsetDiff < Constants.ColorCellHeight {
            cellOffsetY = contentOffsetY
            shrinkingPercent = offsetDiff / Constants.ColorCellHeight
        }
        let insetX = (shrinkingPercent) * collectionView.frame.width / 2
        let insetY = (shrinkingPercent) * Constants.ColorCellHeight / 2
        attributes.frame = CGRect(x: 0, y: cellOffsetY, width: collectionView.frame.width, height: Constants.ColorCellHeight).insetBy(dx: insetX, dy: insetY)
    }
    
}
