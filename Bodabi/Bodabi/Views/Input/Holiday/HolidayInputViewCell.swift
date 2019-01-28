//
//  File.swift
//  Bodabi
//
//  Created by Kim DongHwan on 26/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class HolidayInputViewCell: UITableViewCell {

    @IBOutlet weak var holidaybutton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initHolidayButton()
    }
    
    private func initHolidayButton() {
        holidaybutton.layer.cornerRadius = 10
        holidaybutton.backgroundColor = UIColor.starColor
    }

    @IBAction func touchUpHoildayButton(_ sender: UIButton) {
        sender.pulsate()
    }
}
