//
//  CloudSyncManager.swift
//  Bodabi
//
//  Created by jaehyeon lee on 25/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import CloudKit
import CoreData

extension CloudManager {
    
    static var coreDataManager: CoreDataManager?
    
    static func insertToCloud<CoreDataObject: NSManagedObject>(object: CoreDataObject) {
        
        let record = (object as! CloudManagedObject).convertToRecord()
        CloudManager.insertRecord(record)
    }
    
    static func deleteFromCloud<CoreDataObject: NSManagedObject>(object: CoreDataObject) {
        
        let objectToDelete = object as! CloudManagedObject
        guard let recordName = objectToDelete.recordName else { return }
        let recordID = CKRecord.ID(recordName: recordName, zoneID: self.zoneID)
        CloudManager.deleteRecord(withID: recordID)
    }
    
    static func writeRecordChangeToFriend(record: CKRecord) {
        
        let predicate = NSPredicate(format: "recordName == %@", record.recordID.recordName)
        
        coreDataManager?.fetch(type: Friend.self, predicate: predicate) {
            switch $0 {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(friends):
                if let friend = friends.first {
                    friend.updateWith(record: record, coreDataManager: coreDataManager)
                } else {
//                    coreDataManager?.createFriend(name: "", tags: [], phoneNumber: "") {
//                        switch $0 {
//                        case let .failure(error):
//                            print(error.localizedDescription)
//                        case let .success(friend):
//                            friend.updateWith(record: record, coreDataManager: coreDataManager)
//                        }
//                    }
                }
            }
        }
    }
    
    static func writeRecordChangeToHoliday(record: CKRecord) {
        
        let predicate = NSPredicate(format: "recordName == %@", record.recordID.recordName)
        
            coreDataManager?.fetch(type: Holiday.self, predicate: predicate) {
            switch $0 {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(holidays):
                if let holiday = holidays.first {
                    holiday.updateWith(record: record, coreDataManager: coreDataManager)
                } else {
                    coreDataManager?.createHoliday(title: "", date: Date(), image: nil) {
                        switch $0 {
                        case let .failure(error):
                            print(error.localizedDescription)
                        case let .success(holiday):
                            holiday.updateWith(record: record, coreDataManager: coreDataManager)
                        }
                    }
                }
            }
        }
    }
    
    static func writeRecordChangeToHistory(record: CKRecord) {
        
        let predicate = NSPredicate(format: "recordName == %@", record.recordID.recordName)
        
        coreDataManager?.fetch(type: History.self, predicate: predicate) {
            switch $0 {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(histories):
                if let history = histories.first {
                    history.updateWith(record: record, coreDataManager: coreDataManager)
                } else {
                    let tempFriend = Friend(context: (coreDataManager?.viewContext)!)
                    coreDataManager?.createHistory(holiday: "", item: "", isTaken: false, date: Date(), friend: tempFriend) {
                        switch $0 {
                        case let .failure(error):
                            print(error.localizedDescription)
                        case let .success(history):
                            history.updateWith(record: record, coreDataManager: coreDataManager)
                        }
                    }
                }
            }
        }
    }
    
    static func writeRecordChangeToEvent(record: CKRecord) {
        
        let predicate = NSPredicate(format: "recordName == %@", record.recordID.recordName)
        
        coreDataManager?.fetch(type: Event.self, predicate: predicate) {
            switch $0 {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(events):
                if let event = events.first {
                    event.updateWith(record: record, coreDataManager: coreDataManager)
                } else {
                    let tempFriend = Friend(context: (coreDataManager?.viewContext)!)
                    coreDataManager?.createEvent(title: "", date: Date(), friend: tempFriend) {
                        switch $0 {
                        case let .failure(error):
                            print(error.localizedDescription)
                        case let .success(event):
                            event.updateWith(record: record, coreDataManager: coreDataManager)
                        }
                    }
                }
            }
        }
    }
    
    static func writeRecordChangeToNotification(record: CKRecord) {
        
        let predicate = NSPredicate(format: "recordName == %@", record.recordID.recordName)
        
        coreDataManager?.fetch(type: Notification.self, predicate: predicate) {
            switch $0 {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(notifications):
                if let notification = notifications.first {
                    notification.updateWith(record: record, coreDataManager: coreDataManager)
                } else {
                    let tempEvent = Event(context: (coreDataManager?.viewContext)!)
                    coreDataManager?.createNotification(event: tempEvent, date: Date()) {
                        switch $0 {
                        case let .failure(error):
                            print(error.localizedDescription)
                        case let .success(notification):
                            notification.updateWith(record: record, coreDataManager: coreDataManager)
                        }
                    }
                }
            }
        }
    }
    
    static func writeRecordDeletionToFriend(recordID: CKRecord.ID) {
        let predicate = NSPredicate(format: "recordName == %@", recordID.recordName)
        coreDataManager?.fetch(type: Friend.self, predicate: predicate) {
            switch $0 {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(friends):
                guard let objectToDelete = friends.first else { return }
                coreDataManager?.delete(object: objectToDelete) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    static func writeRecordDeletionToHoliday(recordID: CKRecord.ID) {
        let predicate = NSPredicate(format: "recordName == %@", recordID.recordName)
        coreDataManager?.fetch(type: Holiday.self, predicate: predicate) {
            switch $0 {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(holidays):
                guard let objectToDelete = holidays.first else { return }
                coreDataManager?.delete(object: objectToDelete) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    static func writeRecordDeletionToHistory(recordID: CKRecord.ID) {
        let predicate = NSPredicate(format: "recordName == %@", recordID.recordName)
        coreDataManager?.fetch(type: History.self, predicate: predicate) {
            switch $0 {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(histories):
                guard let objectToDelete = histories.first else { return }
                coreDataManager?.delete(object: objectToDelete) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    static func writeRecordDeletionToEvent(recordID: CKRecord.ID) {
        let predicate = NSPredicate(format: "recordName == %@", recordID.recordName)
        coreDataManager?.fetch(type: Event.self, predicate: predicate) {
            switch $0 {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(events):
                guard let objectToDelete = events.first else { return }
                coreDataManager?.delete(object: objectToDelete) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    static func writeRecordDeletionToNotification(recordID: CKRecord.ID) {
        let predicate = NSPredicate(format: "recordName == %@", recordID.recordName)
        coreDataManager?.fetch(type: Notification.self, predicate: predicate) {
            switch $0 {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(notifications):
                guard let objectToDelete = notifications.first else { return }
                coreDataManager?.delete(object: objectToDelete) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    static func setCoreDataManager(manager: CoreDataManager) {
        coreDataManager = manager
    }
}
