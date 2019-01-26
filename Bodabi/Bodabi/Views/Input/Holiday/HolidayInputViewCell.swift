//
//  File.swift
//  Bodabi
//
//  Created by Kim DongHwan on 26/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class HolidayInputViewCell: UITableViewCell {
    
    @IBOutlet weak var guideLabel: UILabel!
    @IBOutlet weak var holidaybutton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var selectedHoliday: String? {
        didSet {
            setGuideLabel()
            setNextButton()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initGuideLabel()
        initHolidayButton()
        initNextButton()
    }
    
    private func initGuideLabel() {
        guideLabel.text = "어떤 경조사를\n추가하시겠어요?"
    }
    
    private func initNextButton() {
        nextButton.setTitle("완료", for: .normal)
        nextButton.backgroundColor = UIColor.offColor
        nextButton.isEnabled = false
    }
    
    private func initHolidayButton() {
        holidaybutton.layer.cornerRadius = 10
        holidaybutton.backgroundColor = UIColor.starColor
    }
    
    private func setGuideLabel() {
        if selectedHoliday == "+" {
            guideLabel.text = "새로운 경조사를\n추가하시겠어요?"
        } else {
            let attributedString = NSMutableAttributedString()
                .color(holidaybutton.titleLabel?.text ?? "", fontSize: 25)
                .bold("을(를)\n추가하시겠어요?", fontSize: 25)
            guideLabel.attributedText = attributedString
        }
    }
    
    private func setNextButton() {
        if selectedHoliday == "+" {
            nextButton.setTitle("다음", for: .normal)
        } else {
            nextButton.setTitle("완료", for: .normal)
        }
        
        nextButton.backgroundColor = UIColor.mainColor
        nextButton.isEnabled = true
    }
    
    @IBAction func touchUpHoildayButton(_ sender: UIButton) {
        sender.pulsate()
        selectedHoliday = sender.titleLabel?.text
    }
}
