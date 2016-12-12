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
