//
//  Notification.swift
//  Bodabi
//
//  Created by jaehyeon lee on 27/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation

struct Notification {
    let holiday: String
    let date: Date
    let notificationDate: String
    
    // TODO: - Replace property to 'friendID' after database loading
    
    var friendName: String {
        return Friend.dummies[friendId].name
    }
    
    let friendId: Int
    
    // MARK: - Helper Methods
    
    var sentence: String {
        return "2일 뒤 \(self.friendName)님의 \(self.holiday.addObjectSuffix()) 축하해주세요!"
    }
    
    // Dummy Data
    static let dummies: [Notification] = [
        Notification.init(holiday: "생일", date: .init(), notificationDate: "1일 전", friendId: 0),
        Notification.init(holiday: "결혼", date: .init(), notificationDate: "1일 전", friendId: 3),
        Notification.init(holiday: "생일", date: .init(), notificationDate: "1일 전", friendId: 4),
        Notification.init(holiday: "생일", date: .init(), notificationDate: "1일 전", friendId: 6),
        Notification.init(holiday: "생일", date: .init(), notificationDate: "1일 전", friendId: 9),
        Notification.init(holiday: "생일", date: .init(), notificationDate: "1일 전", friendId: 8)]
}
