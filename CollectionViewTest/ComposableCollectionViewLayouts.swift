//
//  ComposableCollectionViewLayouts.swift
//  CollectionViewTest
//
//  Created by Anurag Tolety on 11/12/16.
//  Copyright © 2016 Cow Corner Software. All rights reserved.
//

import Foundation
import UIKit

public protocol ComposableLayoutProvider {
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
    
    /// Determines the direction if the layout supports multiple directions
    var scrollDirection: UICollectionViewScrollDirection { get }
}

/// Represents a layout that can be composed from a list of layout providers that implement the `ComposableLayoutProvider`
/// protocol
open class ComposedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var layoutProviders = [ComposableLayoutProvider]()
    var attributesList = [IndexPath: UICollectionViewLayoutAttributes]()
    
    public init(layoutProviders: [ComposableLayoutProvider]) {
        self.layoutProviders = layoutProviders
        
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) shas not been implemented")
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

public struct FadingLayoutProvider: ComposableLayoutProvider {
    
    let offsetCutOffForFade: CGFloat
    public var scrollDirection: UICollectionViewScrollDirection
    
    public init(offsetCutOffForFade: CGFloat, scrollDirection: UICollectionViewScrollDirection = .vertical) {
        self.offsetCutOffForFade = offsetCutOffForFade
        self.scrollDirection = scrollDirection
    }
    
    public func prepare() {
        
    }
    
    public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    public func adjustItemAttributes(attributes: UICollectionViewLayoutAttributes,
                              forCollectionView collectionView: UICollectionView,
                              atIndexPath indexPath: IndexPath) {
        let isVertical = scrollDirection == .vertical
        var alpha = CGFloat(1.0)
        let contentOffset = isVertical ? collectionView.contentOffset.y : collectionView.contentOffset.x
        let cellOffset = isVertical ? attributes.frame.origin.y : attributes.frame.origin.x
        let offsetDiff = contentOffset - cellOffset
        if offsetDiff > 0 && offsetDiff < offsetCutOffForFade {
            alpha = 1.0 - offsetDiff / offsetCutOffForFade
        }
        attributes.alpha = alpha
        attributes.zIndex = indexPath.item
    }
    
}

public struct ShrinkingLayoutProvider: ComposableLayoutProvider {
    
    let offsetCutOffForShrinking: CGFloat
    public var scrollDirection: UICollectionViewScrollDirection
    
    public init(offsetCutOffForShrinking: CGFloat, scrollDirection: UICollectionViewScrollDirection = .vertical) {
        self.offsetCutOffForShrinking = offsetCutOffForShrinking
        self.scrollDirection = scrollDirection
    }
    
    public func prepare() {
        
    }
    
    public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    public func adjustItemAttributes(attributes: UICollectionViewLayoutAttributes,
                              forCollectionView collectionView: UICollectionView,
                              atIndexPath indexPath: IndexPath) {
        let isVertical = scrollDirection == .vertical
        var cellOffset = isVertical ? attributes.frame.origin.y : attributes.frame.origin.x
        var shrinkingPercent = CGFloat(0)
        let contentOffset = isVertical ? collectionView.contentOffset.y : collectionView.contentOffset.x
        let offsetDiff = contentOffset - cellOffset
        if offsetDiff > 0 && offsetDiff < offsetCutOffForShrinking {
            cellOffset = contentOffset
            shrinkingPercent = offsetDiff / offsetCutOffForShrinking
        }
        let currentWidth = attributes.frame.size.width
        let currentHeight = attributes.frame.size.height
        let insetX = (shrinkingPercent) * currentWidth / 2
        let insetY = (shrinkingPercent) * currentHeight / 2
        let x = isVertical ? 0 : cellOffset
        let y = isVertical ? cellOffset : 0
        attributes.frame = CGRect(x: x, y: y, width: currentWidth, height: currentHeight).insetBy(dx: insetX, dy: insetY)
    }
    
}
