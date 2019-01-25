//
//  UITableViewController+RegisterCells.swift
//  Bodabi
//
//  Created by Kim DongHwan on 25/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

extension UITableViewController {
    func registerCustomCells(nibNames: [String], forCellReuseIdentifiers: [String]) {
        for (index, element) in nibNames.enumerated() {
            tableView.register(UINib(nibName: element, bundle: nil), forCellReuseIdentifier: forCellReuseIdentifiers[index])
        }
    }
}
