//
//  UITableView+Extensions.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 25..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Foundation
import UIKit

protocol TableViewCellType {
    static var identifier: String { get }
}

extension UITableViewCell: TableViewCellType {
    static var identifier: String {
        return String(describing: self.self)
    }
}

extension UITableView {
    func register<Cell: UITableViewCell>(_ reusableCell: Cell.Type) {
        let nib = UINib(nibName: reusableCell.identifier, bundle: nil)
        register(nib, forCellReuseIdentifier: reusableCell.identifier)
    }
    
    func register<Cell: UITableViewCell>(_ reuseableCells: [Cell.Type]) {
        reuseableCells.forEach { (cell) in
            register(cell)
        }
    }
    
    func dequeue<Cell: UITableViewCell>(_ reusableCell: Cell.Type,
                       for indexPath: IndexPath) -> Cell {
        guard let cell = dequeueReusableCell(withIdentifier: reusableCell.identifier,
                                             for: indexPath) as? Cell else {
                                                return Cell()
        }
        return cell
    }
}

