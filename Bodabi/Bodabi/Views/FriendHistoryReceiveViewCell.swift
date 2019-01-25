//
//  FriendHistoryTableViewCell.swift
//  Bodabi
//
//  Created by jaehyeon lee on 25/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class FriendHistoryReceiveViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var holidayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sentenceLabel: UILabel!
    
    // MARK: - Properties
    
    internal var history: History? {
        didSet {
            guard let history = history else {
                holidayLabel.text = ""
                dateLabel.text = ""
                sentenceLabel.text = ""
                return
            }

            holidayLabel.text = history.holiday
            dateLabel.text = history.date
            sentenceLabel.text = "\(history.friendName)님이 \(history.holiday)으로 \(history.item)을 전달해주셨습니다"
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.history = nil
    }
}
