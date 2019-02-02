//
//  CalendarViewStyle.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 1..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Foundation
import UIKit

struct CalendarViewStyle {
    public enum FirstWeekType {
        case monday
        case sunday
        
        func getWeekDay(arr: [String], index: Int) -> String {
            switch self {
            case .monday:
                return arr[(index + 1) % 7]
            case .sunday:
                return arr[index]
            }
        }
    }
    
    public enum CalendarWeekType {
        case long
        case normal
        case short
        
        var weeksArray: [String] {
            let formatter = DateFormatter()
            switch self {
            case .long: return formatter.standaloneWeekdaySymbols
            case .normal: return formatter.shortWeekdaySymbols
            case .short: return formatter.veryShortWeekdaySymbols
            }
        }
    }
    
    public enum CalendarSelectType {
        case squre
        case round
    }
    
    public var scrollOrientation: UIPageViewController.NavigationOrientation = .horizontal
    
    public var firstWeekType: FirstWeekType = .sunday
    public var selectedType: CalendarSelectType = .round
    public var weekType: CalendarWeekType = .short
    
//    public var weekHeaderHeight: CGFloat = 80.0
    public var weekendColor: UIColor = .red
    public var weekColor: UIColor = .gray
    public var dayColor: UIColor = .black
    public var todayColor: UIColor = .blue
    public var selectedColor: UIColor = .yellow
    public var eventColor: UIColor = .red
}
