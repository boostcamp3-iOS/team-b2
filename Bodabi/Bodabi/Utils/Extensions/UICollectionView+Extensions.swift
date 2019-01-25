//
//  UICollectionView+Extensions.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 25..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Foundation
import UIKit

protocol CollectionViewCellType {
    static var identifier: String { get }
}

extension UICollectionViewCell: CollectionViewCellType{
    static var identifier: String {
        return String(describing: self.self)
    }
}

extension UICollectionView {
    func register<Cell: UICollectionViewCell>(_ reusableCell: Cell.Type) {
        let nib = UINib(nibName: reusableCell.identifier, bundle: nil)
        register(nib, forCellWithReuseIdentifier: reusableCell.identifier)
    }
    
    func dequeue<Cell: UICollectionViewCell>(_ reusableCell: Cell.Type,
                                        for indexPath: IndexPath) -> Cell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: reusableCell.identifier,
                                             for: indexPath) as? Cell else {
                                                return Cell()
        }
        return cell
    }
}

