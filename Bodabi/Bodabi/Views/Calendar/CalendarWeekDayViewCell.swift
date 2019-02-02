//
//  CalendarWeekDayViewCell.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 31..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class CalendarWeekDayViewCell: UICollectionViewCell {

    @IBOutlet weak var weekLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    private func setupUI() {
        isUserInteractionEnabled = false
    }
    
    public func configure(weekType: CalendarViewStyle.CalendarWeekType, weekDay: Int) {
        let formatter = DateFormatter()
        switch weekType {
        case .long:
            weekLabel.text = formatter.standaloneWeekdaySymbols[weekDay]
        case .nomal:
            weekLabel.text = formatter.shortWeekdaySymbols[weekDay]
        case .short:
            weekLabel.text = formatter.veryShortWeekdaySymbols[weekDay]
        }
    }
    
    public func setWeekend(_ isWeekend: Bool,
                           weekendColor: UIColor,
                           weekColor: UIColor) {
        if isWeekend {
            weekLabel.textColor = weekendColor
        } else {
            weekLabel.textColor = weekColor
        }
    }
}
