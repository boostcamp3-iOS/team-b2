//
//  FriendsHistoriesViewCell.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 25..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class FriendsHistoriesViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var holidayLabel: UILabel!
    @IBOutlet weak var lastHistoryLabel: UILabel!
    @IBOutlet weak var dDayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func touchUpAddFavoriteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    private func setUpUI() {
        nameLabel.text = "김민수"
        holidayLabel.text = "결혼"
        lastHistoryLabel.text = "생일 50,000"
        dDayLabel.text = "D-23"
    }
}
