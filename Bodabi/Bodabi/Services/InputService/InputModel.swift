//
//  InputModel.swift
//  Bodabi
//
//  Created by Kim DongHwan on 20/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation

enum EntryType: String {
    case addHolidayAtHome
    case addUpcomingEventAtHome
    case addHistoryAtFriendHistory
    case addHistoryAtHoliday
    case addFriendAtFriends
}

enum InputType: String {
    case holiday
    case name
    case item
    case date
    
    var identifier: String {
        switch self {
        case .holiday:
            return HolidayInputViewController.reuseIdentifier
        case .name:
            return NameInputViewController.reuseIdentifier
        case .item:
            return ItemInputViewController.reuseIdentifier
        case .date:
            return DateInputViewController.reuseIdentifier
        }
    }
}

struct InputData {
    var name: String?
    var relation: String?
    var holiday: String?
    var item: Item?
    var date: Date?
    var tags: [String]?
    var isNewData: Bool = true
    
    init() {
        self.name = nil
        self.relation = nil
        self.holiday = nil
        self.item = nil
        self.date = nil
        self.tags = nil
    }
}

