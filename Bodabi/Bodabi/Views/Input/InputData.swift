//
//  InputData.swift
//  Bodabi
//
//  Created by Kim DongHwan on 07/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation

struct InputData {
    var name: String?
    var relation: String?
    var holiday: String?
    var item: Item?
    var date: Date?
    var tags: [String]?
    
    init() {
        self.name = nil
        self.relation = nil
        self.holiday = nil
        self.item = nil
        self.date = nil
        self.tags = nil
    }
}
