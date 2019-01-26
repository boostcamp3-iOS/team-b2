//
//  File.swift
//  Bodabi
//
//  Created by Kim DongHwan on 26/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class HolidayInputViewCell: UITableViewCell {
    
    @IBOutlet weak var holidayTitle: UILabel!
    @IBOutlet weak var holidayBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        holidayBackgroundView.layer.cornerRadius = 10
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
