//
//  CloudManager.swift
//  Bodabi
//
//  Created by Kim DongHwan on 08/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import CloudKit
import CoreData
import Foundation

class CloudManager {
    
    private var databaseManager: DatabaseManager!
    private var friends: [Friend]?
    private var histories: [History]?
    private var holidays: [Holiday]?
    private var events: [Event]?
    private var notifications: [Notification]?
    
    init() {
        fetchAll()
    }
    
//    func uploadAll() {
//
//    }
    
//    func uploadFriend() {
//        guard let friends: [Friend] = friends else { return }
//        friends.forEach { friend in
//            let record = CKRecord(recordType: "Friend")
//        }
//    }
    
    func fetchAll() {
        fetchFriend()
        fetchHoliday()
        fetchHistory()
        fetchEvent()
        fetchNotification()
    }
    
    func fetchFriend() {
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        if let result = try? databaseManager.viewContext.fetch(request) {
            friends = result
        }
    }
    
    func fetchHistory() {
        let request: NSFetchRequest<History> = History.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        if let result = try? databaseManager.viewContext.fetch(request) {
            histories = result
        }
    }
    
    func fetchHoliday() {
        let request: NSFetchRequest<Holiday> = Holiday.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        if let result = try? databaseManager.viewContext.fetch(request) {
            holidays = result
        }
    }
    
    func fetchEvent() {
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        if let result = try? databaseManager.viewContext.fetch(request) {
            events = result
        }
    }
    
    func fetchNotification() {
        let request: NSFetchRequest<Notification> = Notification.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        if let result = try? databaseManager.viewContext.fetch(request) {
            notifications = result
        }
    }
}

// MARK: - DatabaseManagerClient

extension CloudManager: DatabaseManagerClient {
    func setDatabaseManager(_ manager: DatabaseManager) {
        databaseManager = manager
    }
}

// MARK: - Helper Cloud Key Enum

enum FriendKey: String {
    case phoneNumber
    case name
    case favorite
    case tags
    
    var string: String {
        return self.rawValue
    }
}

enum EventKey: String {
    case title
    case favorite
    case date
    case friend
    
    var string: String {
        return self.rawValue
    }
}

enum HistoryKey: String {
    case item
    case holiday
    case isTaken
    case date
    case friend
    
    var string: String {
        return self.rawValue
    }
}

enum HolidayKey: String {
    case title
    case date
    case createdDate
    case image
    
    var string: String {
        return self.rawValue
    }
}

enum NotificationKey: String {
    case isRead
    case isHandled
    case date
    case event
    
    var string: String {
        return self.rawValue
    }
}

//        self[key.string] = newValue as? CKRecordValue
//        }
//    }
//    func save() {
//        let friendRecord = CKRecord(recordType: "Friend")
//
//        friendRecord["name"] = "김동환" as NSString
//
//        let container = CKContainer.default()
//        let privateDatabase = container.privateCloudDatabase
//
//        privateDatabase.save(friendRecord) { (record, error) in
//            if let error = error {
//                print(error.localizedDescription)
//            }
//            print(record)
//        }
//    }
