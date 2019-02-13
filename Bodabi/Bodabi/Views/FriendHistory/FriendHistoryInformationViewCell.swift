//
//  FriendHistoryInformationViewCell.swift
//  Bodabi
//
//  Created by jaehyeon lee on 31/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class FriendHistoryInformationViewCell: UITableViewCell {
    
    // MARK: - IBOutlet

    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expenditureLabel: UILabel!
    @IBOutlet weak var incomeIcon: UIImageView!
    @IBOutlet weak var expenditureIcon: UIImageView!
}

// MARK: - Binding

extension FriendHistoryInformationViewCell: FriendHistoryCellProtocol {
    func bind(item: FriendHistorySectionItem) {
        switch item {
        case let .information(income, expenditure):
            incomeLabel.text = income.insertComma()
            expenditureLabel.text = expenditure.insertComma()
        default:
            return
        }
    }
}
