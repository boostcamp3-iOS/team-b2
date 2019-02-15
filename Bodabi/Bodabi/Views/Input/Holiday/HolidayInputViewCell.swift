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
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initHolidayButton()
        initDeleteButton()
    }
    
    private func initHolidayButton() {
        holidaybutton.layer.cornerRadius = 10
        holidaybutton.backgroundColor = UIColor.starColor
    }
    
    private func initDeleteButton() {
        deleteButton.backgroundColor = .blue
        deleteButton.layer.cornerRadius = 25/2
        deleteButton.isHidden = true
    }

    @IBAction func touchUpHoildayButton(_ sender: UIButton) {
        sender.pulsate()
    }
}
