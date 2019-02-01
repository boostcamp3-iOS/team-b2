//
//  FriendHistorySection.swift
//  Bodabi
//
//  Created by jaehyeon lee on 31/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation

enum FriendHistorySection {
    case information(items: [FriendHistorySectionItem])
    case history(items: [FriendHistorySectionItem])

    // MARK: - Property
    
    var count: Int {
        switch self {
        case .information:
            return 1
        case let .history(items):
            return items.count
        }
    }
    var items: [FriendHistorySectionItem] {
        switch self {
        case let .information(items):
            return items
        case let .history(items):
            return items
        }
    }
}

// MARK: - Type

enum FriendHistorySectionItem {
    case information(income: String, expenditure: String)
    case takeHistory(history: History)
    case giveHistory(history: History)
}

