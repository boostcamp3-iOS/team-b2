//
//  UICollectionViewController+RegisterCells.swift
//  Bodabi
//
//  Created by Kim DongHwan on 25/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

extension UICollectionViewController {
    func registerCustomCells(nibNames: [String], forCellReuseIdentifiers: [String]) {
        for (index, element) in nibNames.enumerated() {
            collectionView.register(UINib(nibName: element, bundle: nil), forCellWithReuseIdentifier: forCellReuseIdentifiers[index])
        }
    }
}
