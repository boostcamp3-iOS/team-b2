
//
//  CalendarDayViewCell.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 31..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class CalendarDayViewCell: UICollectionViewCell {

    // MARK: - IBOutlet
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var eventView: UIView!
    
    // MARK: - Property
    
    public var style: CalendarViewStyle = .init()
    public var day: Int = 0 {
        didSet {
            dayLabel.text = String(format: "%d", day)
        }
    }
    public var events: [Int] = [] {
        didSet {
            eventView.isHidden = !(events.count > 0)
            eventView.backgroundColor = style.eventColor
        }
    }
    public var isToday: Bool = false {
        didSet {
            dayLabel.textColor = isToday ? style.todayColor : style.dayColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpUI()
    }
    
    private func setUpUI() {
        eventView.isHidden = true
    }
    
    // MARK: - Configure
    
    public func configure(daysOfMonth: ClosedRange<Int>) {
        isHidden = !(daysOfMonth ~= day)
        
        guard style.selectedType == .round else { return }
        makeRound(with: .widthRound)
    }
}
