//
//  FriendHistorySendViewCell.swift
//  Bodabi
//
//  Created by jaehyeon lee on 25/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class FriendHistorySendViewCell: UITableViewCell {

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
            dateLabel.text = history.date.toString(of: .none)
            sentenceLabel.text = history.giveSentence
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.history = nil
    }
}
