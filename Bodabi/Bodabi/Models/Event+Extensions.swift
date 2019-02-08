//
//  Event+Extensions.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 8..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Foundation

extension Event {
    
    // MARK: - Helper
    
    var dday: Int {
        if let date = self.date {
            return date.offsetFrom(date: Date())
        }
        return 0
    }
}
