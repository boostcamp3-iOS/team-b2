//
//  Holiday.swift
//  Bodabi
//
//  Created by Kim DongHwan on 29/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation

struct Holiday {
    var title: String
    var image: Data?
    var usedCount: Int = 0
    
    static var dummies: [Holiday] = [
        Holiday(title: "내 결혼식", image: nil, usedCount: 0),
        Holiday(title: "어머니 장례식", image: nil, usedCount: 0),
        Holiday(title: "동생 결혼식", image: nil, usedCount: 0),
        Holiday(title: "내 생일", image: nil, usedCount: 0),
        Holiday(title: "아버지 환갑잔치", image: nil, usedCount: 0)
    ]
}
