//
//  ViewController.swift
//  CollectionViewTest
//
//  Created by Anurag Tolety on 12/6/16.
//  Copyright © 2016 Cow Corner Software. All rights reserved.
//

import UIKit

struct Constants {
    static let ColorCellHeight = CGFloat(150)
}

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var colorStore = [IndexPath: UIColor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let layoutProviders: [ComposableLayoutProvider] = [FirstCellFadingLayoutProvider(), FirstCellShrinkingLayoutProvider()]
        let layout = ComposedCollectionViewFlowLayout(layoutProviders: layoutProviders)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: self.view.frame.width, height: Constants.ColorCellHeight)
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let colorCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCellIdentifier", for: indexPath)
        if let storedColor = colorStore[indexPath] {
            colorCell.backgroundColor = storedColor
        } else {
            let red = CGFloat(arc4random_uniform(255)) / 255
            let blue = CGFloat(arc4random_uniform(255)) / 255
            let green = CGFloat(arc4random_uniform(255)) / 255
            let backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
            colorStore[indexPath] = backgroundColor
            colorCell.backgroundColor = backgroundColor
        }
        return colorCell
    }
    
}

protocol ComposableLayoutProvider {
    func prepare()
    func adjustItemAttributes(attributes: UICollectionViewLayoutAttributes,
                              forCollectionView collectionView: UICollectionView,
                              atIndexPath indexPath: IndexPath)
    func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
}

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
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return layoutProviders.reduce(true, { (result, layout) -> Bool in
            return result && layout.shouldInvalidateLayout(forBoundsChange: newBounds)
        })
    }
    
    override func prepare() {
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
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
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
