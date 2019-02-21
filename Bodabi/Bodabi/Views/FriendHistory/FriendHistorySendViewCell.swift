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
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet var deleteButtonConstraint: NSLayoutConstraint!
}

// MARK: - Binding

extension FriendHistorySendViewCell: FriendHistoryCellProtocol {
    var button: UIButton {
        return self.deleteButton
    }
    
    func bind(item: FriendHistorySectionItem) {
        switch item {
        case let .giveHistory(giveHistory):
            holidayLabel.text = giveHistory.holiday
            dateLabel.text = giveHistory.date?.toString(of: .year)
            sentenceLabel.text = giveHistory.giveSentence
        default:
            return
        }
    }
    
    func showDeleteButton() {
        deleteButton.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.deleteButtonConstraint.isActive = false
            self.layoutIfNeeded()
        }) { (_) in
            self.deleteButton.setScaleAnimation(scale: 1.12, duration: 0.12)
        }
    }
    
    func hideDeleteButton() {
        UIView.animate(withDuration: 0.3, animations: {
            self.deleteButtonConstraint.isActive = true
            self.layoutIfNeeded()
        }) { (_) in
            self.deleteButton.isHidden = true
        }
    }
}
