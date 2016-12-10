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
        let layout = ColorViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: self.view.frame.width, height: 150)
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

class ColorViewFlowLayout: UICollectionViewFlowLayout {

    private var attributesList = [UICollectionViewLayoutAttributes]()
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func prepare() {
        super.prepare()
        
        attributesList.removeAll(keepingCapacity: true)
        for item in 0..<collectionView!.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            var cellOffsetY = CGFloat(indexPath.item) * Constants.ColorCellHeight
            var alpha = CGFloat(1.0)
            let contentOffsetY = collectionView!.contentOffset.y
            let offsetDiff = contentOffsetY - cellOffsetY
            if offsetDiff > 0 && offsetDiff < Constants.ColorCellHeight {
                cellOffsetY = contentOffsetY
                alpha = 1.0 - offsetDiff / Constants.ColorCellHeight
            }
            let insetX = (1.0 - alpha) * collectionView!.frame.width / 2
            let insetY = (1.0 - alpha) * Constants.ColorCellHeight / 2
            attributes.frame = CGRect(x: 0, y: cellOffsetY, width: collectionView!.frame.width, height: Constants.ColorCellHeight).insetBy(dx: insetX, dy: insetY)
            attributes.alpha = alpha
            attributes.zIndex = indexPath.item
            attributesList.append(attributes)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesList.filter({ (attributes) -> Bool in
            attributes.frame.intersects(rect)
        })
    }
    
}

