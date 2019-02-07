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
    var holiday: String?
    var item: Item?
    var date: Date?
    
    init() {
        self.name = nil
        self.holiday = nil
        self.item = nil
        self.date = nil
    }
}
