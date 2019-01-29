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
        
        var description: String {
            switch self {
            case .year:
                return "yyyy.MM.dd"
            case .none:
                return "MM.dd"
            }
        }
    }
    
    func toString(of type: FormatType) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = type.description
        return dateFormatter.string(from: self)
    }
}
