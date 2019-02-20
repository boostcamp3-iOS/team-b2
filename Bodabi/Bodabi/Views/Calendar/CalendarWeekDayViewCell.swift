//
//  CalendarWeekDayViewCell.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 31..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class CalendarWeekDayViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlet

    @IBOutlet weak var weekLabel: UILabel!
    
    // MARK: - Property
    
    public var style: CalendarViewStyle = .init()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    private func setupUI() {
        isUserInteractionEnabled = false
    }
    
    // MARK: - Configure
    
    public func configure(index: Int) {
        let weeksArray = style.weekType.weeksArray
        let week = style.firstWeekType.getWeekDay(weeks: weeksArray, index: index)
        weekLabel.text = week
        
        guard let weekFirstCharacter = week.first else { return }
        if style.weekType == .korean {
            weekLabel.textColor = String(weekFirstCharacter) == "일" || String(weekFirstCharacter) ==  "토" ?
                style.weekendColor : style.weekColor
        } else {
            weekLabel.textColor = String(weekFirstCharacter) == "S" ? style.weekendColor : style.weekColor
        }
    }
}
