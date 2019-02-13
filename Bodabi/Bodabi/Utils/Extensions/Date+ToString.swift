//
//  Date+ToString.swift
//  Bodabi
//
//  Created by Kim DongHwan on 29/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation

extension Date {
    enum FormatType {
        case year
        case none
        case noDay
        case time
        
        var description: String {
            switch self {
            case .year:
                return "yyyy.MM.dd"
            case .none:
                return "MM.dd"
            case .noDay:
                return "yyyy.MM"
            case .time:
                return "yyyy.MM.dd hh:mm"
            }
        }
    }
    
    func toString(of type: FormatType) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = type.description
        return dateFormatter.string(from: self)
    }
    
    func offsetFrom(date : Date) -> Int {
        let calendar: Calendar = Calendar.current
        let eventDateComponents = calendar.dateComponents([.era, .year, .month, .day], from: self)
        let todayDateComponents = calendar.dateComponents(
            [.era, .year, .month, .day], from: date)
        let difference = calendar.dateComponents([.day], from: todayDateComponents, to: eventDateComponents)
        if let dday = difference.day {
            return dday
        }
        return 0
    }
}

extension Date: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        self = formatter.date(from: value) ?? Date()
    }
}
