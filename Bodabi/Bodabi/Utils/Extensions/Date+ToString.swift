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
        
        var description: String {
            switch self {
            case .year:
                return "yyyy.MM.dd"
            case .none:
                return "MM.dd"
            case .noDay:
                return "yyyy.MM"
            }
        }
    }
    
    func toString(of type: FormatType) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = type.description
        return dateFormatter.string(from: self)
    }
    
    func offsetFrom(date : Date) -> Int {
        let difference = NSCalendar.current.dateComponents([.day], from: date, to: self);
        if let day = difference.day, day > 0 {
            return day
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
