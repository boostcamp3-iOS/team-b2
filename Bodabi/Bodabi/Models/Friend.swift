//
//  Friend.swift
//  Bodabi
//
//  Created by Kim DongHwan on 29/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation

struct Friend {
    var id: Int
    var name: String
    var phoneNumber: String?
    var tag: [String]?
    var favorite: Bool = false
    
    static var dummies: [Friend] = [
        Friend(id: 0, name: "나", phoneNumber: "01012341234", tag: nil, favorite: false),
        Friend(id: 1, name: "김철수", phoneNumber: "01012342345", tag: nil, favorite: false),
        Friend(id: 2, name: "박영희", phoneNumber: "01012343456", tag: nil, favorite: false),
        Friend(id: 3, name: "성시경", phoneNumber: "01012344567", tag: nil, favorite: false),
        Friend(id: 4, name: "박효신", phoneNumber: "01012341234", tag: nil, favorite: false),
        Friend(id: 5, name: "거미", phoneNumber: "01012341234", tag: nil, favorite: false),
        Friend(id: 6, name: "이재현", phoneNumber: "01012341234", tag: ["부캠"], favorite: false),
        Friend(id: 7, name: "이혜진", phoneNumber: "01012341234", tag: ["부캠"], favorite: false),
        Friend(id: 8, name: "김동환", phoneNumber: "01012341234", tag: ["부캠"], favorite: false),
        Friend(id: 9, name: "최완복", phoneNumber: "01012341234", tag: nil, favorite: true),
        Friend(id: 10, name: "김정정", phoneNumber: "01012341234", tag: nil, favorite: true),
        Friend(id: 10, name: "윤현국", phoneNumber: "01012341234", tag: nil, favorite: true),
        Friend(id: 10, name: "오진성", phoneNumber: "01012341234", tag: nil, favorite: true),
        Friend(id: 10, name: "야곰곰", phoneNumber: "01012341234", tag: nil, favorite: true)
    ]
}
