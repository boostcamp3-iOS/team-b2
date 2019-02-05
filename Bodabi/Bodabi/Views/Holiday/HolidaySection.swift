//
//  HolidaySection.swift
//  Bodabi
//
//  Created by Kim DongHwan on 05/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

enum HolidaySection {
    case information(items: [HolidaySectionItem])
    case thanksFriend(items: [HolidaySectionItem])
    
    // MARK: - Property
    
    var count: Int {
        switch self {
        case .information:
            return 1
        case let .thanksFriend(items):
            return items.count
        }
    }
    var items: [HolidaySectionItem] {
        switch self {
        case let .information(items):
            return items
        case let .thanksFriend(items):
            return items
        }
    }
}

// MARK: - Type

enum HolidaySectionItem {
    case information(income: String, image: UIImage?)
    case thanksFriend(name: String, item: String)
}
