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
    let date: String
    let nofiticationDate: String
    
    // TODO: - Replace property to 'friendID' after database loading
    let friendName: String
    
    // MARK: - Helper Methods
    
    var sentence: String {
        return "2일 뒤 \(self.friendName)님의 \(self.holiday.addObjectSuffix()) 축하해주세요!"
    }
    
    // Dummy Data
    static let dummyNotifications: [Notification] = [
        Notification.init(holiday: "생일", date: "2019.01.25", nofiticationDate: "1일 전", friendName: "김철수"),
        Notification.init(holiday: "결혼", date: "2019.01.28", nofiticationDate: "1일 전", friendName: "김철수"),
        Notification.init(holiday: "생일", date: "2019.01.25", nofiticationDate: "1일 전", friendName: "박영희"),
        Notification.init(holiday: "생일", date: "2019.01.25", nofiticationDate: "1일 전", friendName: "문재인"),
        Notification.init(holiday: "생일", date: "2019.01.25", nofiticationDate: "1일 전", friendName: "김민수"),
        Notification.init(holiday: "생일", date: "2019.01.25", nofiticationDate: "1일 전", friendName: "이문세")]
}
