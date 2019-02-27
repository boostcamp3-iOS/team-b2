////
////  CloudKitManager.swift
////  Bodabi
////
////  Created by jaehyeon lee on 24/02/2019.
////  Copyright © 2019 LeeHyeJin. All rights reserved.
////
//
//import CloudKit
//
//public protocol CloudKitManagerProtocol {
//    func cloudRecordChanged(record: CKRecord)
//}
//
//final class CloudKitManager {
//    
//    private let container = CKContainer.default()
//    private let privateDatabase = CKContainer.default().privateCloudDatabase
//    private var delegate: CloudKitManagerProtocol?
//
//    let subscriptionID: String = "subscriptionBodabi"
//    var zoneID: CKRecordZone.ID?
//    
//    init() {}
//    
//    func checkCurrentSubscriptions(zone: RecordZone) {
//        privateDatabase.fetchAllSubscriptions { subscriptions, error in
//            if let error = error {
//                print(error.localizedDescription)
//            }
//            
//            if let subscriptions = subscriptions {
//                if subscriptions.first(where: { $0.subscriptionID == zone.subscriptionID }) == nil {
//                    self.subscribeTo(zone: zone)
//                }
//            }
//        }
//    }
//        
//    func subscribeTo(zone: RecordZone) {
//        guard let subscription = zone.subscription else { return }
//        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription],
//                                                       subscriptionIDsToDelete: nil)
//
//        
//        operation.modifySubscriptionsCompletionBlock = { subscriptions, _ , error in
//            if let error = error {
//                print(error.localizedDescription)
//            }
//            if let subscriptionID = subscriptions?.first?.subscriptionID {
//                print("Saved Subscription with \(subscriptionID)")
//            }
//        }
//        zone.database?.add(operation)
//    }
//        
//    func setup(zone: RecordZone) {
//        let zoneName = zone.description
//        zone.database?.save(CKRecordZone(zoneName: zoneName)) {
//            recordZone, error in
//            if let error = error {
//                print(error.localizedDescription)
//            }
//            print(recordZone!)
//        }
//    }
//    
//    func checkCloudKitSubscriptions() {
//        
//        checkCurrentSubscriptions(zone: CloudZone.private)
//        checkCurrentSubscriptions(zone: CloudZone.shared)
//    }
//    
//    
////    func subscribe() {
////
////        let subscription = CKDatabaseSubscription(subscriptionID: subscriptionID)
////        privateDatabase.save(subscription) {
////            subscriptionID, error in
////            if error != nil {
////                print(error?.localizedDescription)
////            }
////            print(subscription)
////        }
////        let subscription = CKRecordZoneSubscription(zoneID: CloudKitManager.customZone.zoneID, subscriptionID: subscriptionID)
////        let notificationInfo = CKSubscription.NotificationInfo()
////        notificationInfo.shouldSendContentAvailable = true
////        subscription.notificationInfo = notificationInfo
////
////        let subscriptionOperation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])
////        subscriptionOperation.modifySubscriptionsCompletionBlock = {
////            (_, _, error) in
////            if let error = error {
////                print(error.localizedDescription)
////            } else {
////                UserDefaults.standard.set(true, forKey: DefaultsKey.customZoneSubscription)
////            }
////        }
////        privateDatabase.add(subscriptionOperation)
//
////    func loadZone() {
////        privateDatabase.fetch(withRecordZoneID: zoneID ?? CloudKitManager.customZone.zoneID) {
////            [weak self] retrievedZone, error in
////            if error != nil {
////                print(error!.localizedDescription)
////            let ckError = error! as NSError
////                if ckError.code == CKError.zoneNotFound.rawValue {
////                    self?.privateDatabase.save(CloudKitManager.customZone) {
////                        newZone, error in
////                        if error != nil {
////                            print(error!.localizedDescription)
////                        } else {
////                            guard let retrievedZone = retrievedZone else { return }
////                            CloudKitManager.customZone = retrievedZone
////                        }
////                    }
////                } else {
////                    if let retrievedZone = retrievedZone {
////                        CloudKitManager.customZone = retrievedZone
////                    }
////                }
////            }
////        }
////    }
////    
////    func fetchCloudChanges() {
////        var changeToken: CKServerChangeToken!
////        var changeZoneToken: CKServerChangeToken!
////        
////        guard let zoneID = zoneID else { return }
////
////        let configuration = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
////        configuration.previousServerChangeToken = changeZoneToken
////        let fetchOperation = CKFetchRecordZoneChangesOperation(recordZoneIDs: [zoneID], configurationsByRecordZoneID: [zoneID: configuration])
////        fetchOperation.recordZoneFetchCompletionBlock
////            
////            CKFetchRecordZoneChangesOperation(recordZoneIDs: [zoneID], configurationsByRecordZoneID: [CKRecordZone.ID : CKFetchRecordZoneChangesOperation.ZoneConfiguration]?)
////        }
//
//}
