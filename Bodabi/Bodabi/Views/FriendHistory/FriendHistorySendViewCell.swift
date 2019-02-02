//
//  FriendHistorySendViewCell.swift
//  Bodabi
//
//  Created by jaehyeon lee on 25/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class FriendHistorySendViewCell: UITableViewCell {

    // MARK: - IBOutlet
    
    @IBOutlet weak var holidayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sentenceLabel: UILabel!
}

// MARK: - Binding

extension FriendHistorySendViewCell: FriendHistoryCellProtocol {
    func bind(item: FriendHistorySectionItem) {
        switch item {
        case let .giveHistory(giveHistory):
            holidayLabel.text = giveHistory.holiday
//            dateLabel.text = giveHistory.date.toString(of: .none)
//            sentenceLabel.text = giveHistory.giveSentence
        default:
            return
        }
    }
}
