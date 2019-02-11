//
//  FriendHistoryTableViewCell.swift
//  Bodabi
//
//  Created by jaehyeon lee on 25/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class FriendHistoryReceiveViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var holidayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sentenceLabel: UILabel!
}

// MARK: - Binding

extension FriendHistoryReceiveViewCell: FriendHistoryCellProtocol {
    func bind(item: FriendHistorySectionItem) {
        switch item {
        case let .takeHistory(takeHistory):
            holidayLabel.text = takeHistory.holiday
            dateLabel.text = takeHistory.date?.toString(of: .year)
            sentenceLabel.text = takeHistory.takeSentence
        default:
            return
        }
    }
}
