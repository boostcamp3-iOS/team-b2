//
//  Item.swift
//  Bodabi
//
//  Created by Kim DongHwan on 05/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation

enum Item {
    case cash(amount: String)
    case gift(name: String)
    
    var text: String {
        switch self {
        case .cash:
            return "금액"
        case .gift:
            return "선물"
        }
    }
    
    var placeholder: String {
        switch self {
        case .cash:
            return "원"
        case .gift:
            return "기프티콘"
        }
    }
    
    var list: [String] {
        switch  self {
        case .cash:
            return ["10000", "30000", "50000", "70000", "100000", "200000"]
        case .gift:
            return ["꽃", "기프티콘", "냉장고", "전자레인지", "옷", "케이크", "화장품", "상품권"]
        }
    }
    
    var value: String {
        switch self {
        case let .cash(amount):
            return amount
        case let .gift(name):
            return name
        }
    }
}
