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
    }
    
    public enum CalendarSelectType {
        case squre
        case round
    }
    
    public enum CalendarWeekType {
        case long
        case nomal
        case short
    }
    
    public var scrollOrientation: UIPageViewController.NavigationOrientation = .horizontal
    
    public var firstWeekType: FirstWeekType = .sunday
    public var selectedType: CalendarSelectType = .round
    public var weekType: CalendarWeekType = .short
    
    public var weekendColor: UIColor = .red
    public var weekColor: UIColor = .gray
    public var dayColor: UIColor = .black
    public var todayColor: UIColor = .blue
    public var selectedColor: UIColor = .yellow
    public var eventColor: UIColor = .red
}
