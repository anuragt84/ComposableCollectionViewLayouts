//
//  CollectionViewTypesViewController.swift
//  CollectionViewTest
//
//  Created by Anurag Tolety on 12/17/16.
//  Copyright © 2016 Cow Corner Software. All rights reserved.
//

import Foundation
import UIKit

enum CollectionViewTypesDataSource: Int {
    case vertical, horizontal, circular
    
    var stringValue: String {
        var typeString = ""
        switch self {
        case .vertical:
            typeString = "Vertical"
        case .horizontal:
            typeString = "Horizontal"
        case .circular:
            typeString = "Circular"
        }
        
        return typeString
    }
    
    var segueIdentifier: String {
        var identifier = ""
        switch self {
        case .vertical:
            identifier = "ShowVerticalCollectionView"
        case .horizontal:
            identifier = "ShowHorizontalCollectionView"
        case .circular:
            identifier = "ShowCircularCollectionView"
        }
        
        return identifier
    }
    
    static let count = 3
}

private extension Constants {
    static let collectionViewTypeCellIdentifier = "collectionViewTypeCellIdentifier"
}

class CollectionViewTypesViewController: UIViewController {
    
    @IBOutlet weak var collectionViewTypesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionViewTypesTableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: Constants.collectionViewTypeCellIdentifier)
        collectionViewTypesTableView.delegate = self
        collectionViewTypesTableView.dataSource = self
    }
}

extension CollectionViewTypesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CollectionViewTypesDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.collectionViewTypeCellIdentifier)!
        cell.textLabel?.text = CollectionViewTypesDataSource(rawValue: indexPath.row)?.stringValue
        
        return cell
    }
    
}

extension CollectionViewTypesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let collectionViewType = CollectionViewTypesDataSource(rawValue: indexPath.row)!
        //navigationController?.show(verticalCollectionVC, sender: nil)
        //navigationController?.performSegue(withIdentifier: collectionViewType.segueIdentifier, sender: nil)
        performSegue(withIdentifier: collectionViewType.segueIdentifier, sender: nil)
    }
    
}