//
//  CloudManager.swift
//  Bodabi
//
//  Created by jaehyeon lee on 25/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import CloudKit

private let customZoneName = "CloudZone"

final class CloudManager {
    
    static var privateDatabase: CKDatabase {
        return CKContainer.default().privateCloudDatabase
    }
    
    static let zoneID = CKRecordZone.ID(zoneName: customZoneName, ownerName: CKCurrentUserDefaultName)
    
    static let createZoneDispatchGroup = DispatchGroup()
    
    init() {}
    
    static func iCloudIsAvailable() -> Bool {
        if FileManager.default.ubiquityIdentityToken != nil {
            print("cloud task is available")
            return true
        } else {
            print("cloud task is not available")
            return false
        }
    }
    
    static func insertRecord(_ newRecord: CKRecord) {
        if !CloudManager.iCloudIsAvailable() {
            return
        }
        
        self.privateDatabase.fetch(withRecordID: newRecord.recordID) { (fetchedRecord, error) in
            if let error = error as? CKError {
                print("Error fetching record:", error)
                
                if error.code == CKError.unknownItem {
                    print("No record found with recordID:", newRecord.recordID)
                    
                    self.privateDatabase.save(newRecord) { (_, error) in
                        if let error = error {
                            print("Error saving new record:", error)
                        }
                    }
                }
            } else if let fetchedRecord = fetchedRecord {
                self.privateDatabase.delete(withRecordID: fetchedRecord.recordID) { (_, error) in
                    if let error = error {
                        print("Error deleting record:", error)
                    } else {
                        self.privateDatabase.save(newRecord) {
                            (_, error) in
                            if let error = error {
                                print("Error saving new record:", error)
                            }
                        }
                    }
                }
            }
        }
    }
    
    static func deleteRecord(withID recordID: CKRecord.ID) {
        if !CloudManager.iCloudIsAvailable() {
            return
        }
        
        self.privateDatabase.delete(withRecordID: recordID) { (recordID, error) in
            if let error = error {
                print("Error deleting record:", error)
            }
        }
    }
    
    static func createCustomZone() {
        if !CloudManager.iCloudIsAvailable() {
            return
        }
        
        let createdCustomZone = UserDefaults.standard.bool(forKey: DefaultsKey.createdCustomZoneBefore)
        
        if !createdCustomZone {
            self.createZoneDispatchGroup.enter()
            
            let customZone = CKRecordZone(zoneID: self.zoneID)
            let createZoneOperation = CKModifyRecordZonesOperation(recordZonesToSave: [customZone], recordZoneIDsToDelete: [])
            
            createZoneOperation.modifyRecordZonesCompletionBlock = { (saved, deleted, error) in
                if error != nil {
                    print("Error creating custom zone: \(String(describing: error))")
                } else {
                    UserDefaults.standard.set(true, forKey: DefaultsKey.createdCustomZoneBefore)
                }
                
                self.createZoneDispatchGroup.leave()
            }
            createZoneOperation.qualityOfService = .userInitiated
            
            self.privateDatabase.add(createZoneOperation)
        }
    }
    
    static func subscribeToChanges() {
        if !CloudManager.iCloudIsAvailable() {
            return
        }
        
        let subscribedToPrivateChanges = UserDefaults.standard.bool(forKey: DefaultsKey.subscribedToPrivateChanges)
        
        if !subscribedToPrivateChanges {
            let subscription = CKDatabaseSubscription(subscriptionID: "privateChanges")
            
            let notificationInfo = CKSubscription.NotificationInfo()
            notificationInfo.shouldSendContentAvailable = true
            subscription.notificationInfo = notificationInfo
            
            let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])
            operation.qualityOfService = .utility
            
            operation.modifySubscriptionsCompletionBlock = { (subscriptions, deletedIDs, error) in
                if error != nil {
                    print("Error subscribing to changes: \(String(describing: error))")
                } else {
                    UserDefaults.standard.set(true, forKey: DefaultsKey.subscribedToPrivateChanges)
                }
            }
            
            self.privateDatabase.add(operation)
        }
        
        self.createZoneDispatchGroup.notify(queue: DispatchQueue.global()) {
            let createdCustomZone = UserDefaults.standard.bool(forKey: DefaultsKey.createdCustomZoneBefore)
            
            if createdCustomZone {
                CloudManager.pull { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    static func pull(completion: @escaping (Error?) -> Void) {
        if !CloudManager.iCloudIsAvailable() {
            return
        }
        
        var changeToken: CKServerChangeToken? = nil
        let changeTokenData = UserDefaults.standard.data(forKey: DefaultsKey.zoneChangeToken)
        
        if changeTokenData != nil {
            do {
                changeToken = try NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: changeTokenData!)
            } catch {
                changeToken = nil
                completion(error)
            }
        }
        
        let configuration = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
        configuration.previousServerChangeToken = changeToken
        
        let operation = CKFetchRecordZoneChangesOperation(recordZoneIDs: [self.zoneID], configurationsByRecordZoneID: [self.zoneID : configuration])
        operation.fetchAllChanges = true
        
        operation.recordChangedBlock = { (record) in
            print("recordChangedBlock")
            switch record.recordType {
            case RemoteType.friend:
                CloudManager.writeRecordChangeToFriend(record: record)
            case RemoteType.holiday:
                CloudManager.writeRecordChangeToFriend(record: record)
            case RemoteType.history:
                CloudManager.writeRecordChangeToFriend(record: record)
            case RemoteType.event:
                CloudManager.writeRecordChangeToFriend(record: record)
            case RemoteType.notification:
                CloudManager.writeRecordChangeToFriend(record: record)
            default:
                break
            }
        }
        
        operation.recordWithIDWasDeletedBlock = { (recordID, recordType) in
            print("recordDeletedBlock")
            switch recordType {
            case RemoteType.friend:
                CloudManager.writeRecordDeletionToFriend(recordID: recordID)
            case RemoteType.holiday:
                CloudManager.writeRecordDeletionToFriend(recordID: recordID)
            case RemoteType.history:
                CloudManager.writeRecordDeletionToFriend(recordID: recordID)
            case RemoteType.event:
                CloudManager.writeRecordDeletionToFriend(recordID: recordID)
            case RemoteType.notification:
                CloudManager.writeRecordDeletionToFriend(recordID: recordID)
            default:
                break
            }
        }
        
        operation.recordZoneChangeTokensUpdatedBlock = { (zoneID, token, data) in
            try? coreDataManager?.viewContext.save()
            
            guard let changeToken = token else {
                print("Error getting new changeToken")
                return
            }
            
            do {
                let changeTokenData = try NSKeyedArchiver.archivedData(withRootObject: changeToken, requiringSecureCoding: true)
                UserDefaults.standard.set(changeTokenData, forKey: DefaultsKey.zoneChangeToken)
            } catch {
                print("Error archiving new changeToken")
                completion(error)
            }
        }
        
        operation.recordZoneFetchCompletionBlock = { (zoneID, token, _, _, error) in
            print("recordZoneFetchCompletionBlock")
            if let error = error {
                print("Error fetching zone changes:", error)
                return
            }
            
            try? coreDataManager?.viewContext.save()
            
            guard let changeToken = token else {
                print("Error getting new changeToken")
                return
            }
            
            do {
                let changeTokenData = try NSKeyedArchiver.archivedData(withRootObject: changeToken, requiringSecureCoding: true)
                UserDefaults.standard.set(changeTokenData, forKey: DefaultsKey.zoneChangeToken)
            } catch {
                print("Error archiving new changeToken")
                completion(error)
            }
        }
        
        operation.fetchRecordZoneChangesCompletionBlock = { (error) in
            print("fetchRecordZoneChangesCompletionBlock")
            
            if let error = error {
                print("Error fetching zone changes:", error)
            }
            completion(nil)
        }
        self.privateDatabase.add(operation)
    }
}
