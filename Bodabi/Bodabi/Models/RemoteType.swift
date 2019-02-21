//
//  RecordType.swift
//  Bodabi
//
//  Created by jaehyeon lee on 21/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation

enum RemoteType {
    static let friend = "Friend"
    static let holiday = "Holiday"
    static let history = "History"
    static let event = "Event"
    static let notification = "Notification"
}

enum RemoteFriend {
    static let phoneNumber = "phoneNumber"
    static let name = "name"
    static let favorite = "favorite"
    static let tags = "tags"
}

enum RemoteEvent {
    static let title = "title"
    static let favorite = "favorite"
    static let date = "date"
    static let friend = "friend"
}

enum RemoteHistory {
    static let item = "item"
    static let holiday = "holiday"
    static let isTaken = "isTaken"
    static let date = "date"
    static let friend = "friend"
}

enum RemoteHoliday {
    static let title = "title"
    static let date = "date"
    static let createdDate = "createdDate"
    static let image = "image"
}

enum RemoteNotification {
    static let isRead = "isRead"
    static let isHandled = "isHandled"
    static let date = "date"
    static let event = "event"
}
