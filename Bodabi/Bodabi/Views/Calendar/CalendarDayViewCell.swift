
//
//  CalendarDayViewCell.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 31..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class CalendarDayViewCell: UICollectionViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var eventView: UIView!
    
    var selectedType: CalendarViewStyle.CalendarSelectType = .round {
        didSet {
            switch selectedType {
            case .squre:
                break
            case .round:
                makeRound(with: .widthRound)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func configure(_ day: Int, isDayOfMonth: Bool, events: [Int] = []) {
        dayLabel.text = "\(day)"
        isHidden = !isDayOfMonth
        
        eventView.isHidden = !(events.count > 0)
    }
    
    public func setToday(_ isToday: Bool, todayColor: UIColor, dayColor: UIColor) {
        dayLabel.textColor = isToday ? todayColor : dayColor
    }

}
