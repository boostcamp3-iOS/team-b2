//
//  Event.swift
//  Bodabi
//
//  Created by Kim DongHwan on 29/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation

struct Event {
    var friendId: Int
    var holiday: String
    var date: Date
    
    static var dummies: [Event] = [
        Event(friendId: 0, holiday: "결혼", date: .init()),
        Event(friendId: 1, holiday: "결혼", date: .init()),
        Event(friendId: 4, holiday: "졸업식", date: .init()),
        Event(friendId: 2, holiday: "생일", date: .init()),
        Event(friendId: 3, holiday: "취직", date: .init()),
        Event(friendId: 1, holiday: "출산", date: .init()),
        Event(friendId: 1, holiday: "출산", date: .init()),
        Event(friendId: 8, holiday: "입학식", date: .init()),
        Event(friendId: 7, holiday: "퇴사", date: .init()),
        Event(friendId: 10, holiday: "생일", date: .init()),
        Event(friendId: 5, holiday: "개업", date: .init())
    ]
    
}
