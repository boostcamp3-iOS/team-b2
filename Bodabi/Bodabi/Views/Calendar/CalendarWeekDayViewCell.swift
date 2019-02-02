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
    
    public var style: CalendarViewStyle = .init()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    private func setupUI() {
        isUserInteractionEnabled = false
    }
    
    public func configure(index: Int) {
        let weeksArray = style.weekType.weeksArray
        let week = style.firstWeekType.getWeekDay(arr: weeksArray, index: index)
        weekLabel.text = week
        
        guard let weekFirstCharacter = week.first else { return }
        weekLabel.textColor = String(weekFirstCharacter) == "S" ? style.weekendColor : style.weekColor
    }
}
