//
//  RecordZone.swift
//  Bodabi
//
//  Created by jaehyeon lee on 25/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import CloudKit

protocol RecordZone: CustomStringConvertible {
    
    var databaseType: DatabaseType { get }
    init(databaseType: DatabaseType)
}

extension RecordZone {
    
    var description: String {
        return Self.description
    }
    
    static var description: String {
        return "\(Self.self)"
    }
    
    private var databaseZoneDescription: String {
        return databaseType.description + description
    }
    
    var didSetupZone: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "DidSetup" + databaseZoneDescription)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "DidSetup" + databaseZoneDescription)
        }
    }
    
    static var zone: CKRecordZone {
        return CKRecordZone(zoneName: Self.description)
    }
    
    static var zoneID: CKRecordZone.ID {
        return zone.zoneID
    }
    
    var database: CKDatabase? {
        switch databaseType {
        case .public:
            return CKContainer.default().publicCloudDatabase
        case .private:
            return CKContainer.default().privateCloudDatabase
        case .shared:
            return CKContainer.default().sharedCloudDatabase
        }
    }
    
    var subscription: CKSubscription? {
        var subscription: CKSubscription? = nil
        switch databaseType {
        case .public:
            break
        case .private:
            subscription = CKRecordZoneSubscription(zoneID: Self.zoneID,
                                                        subscriptionID: subscriptionID)
        case .shared:
            subscription = CKDatabaseSubscription(subscriptionID: subscriptionID)
        }
        
        subscription?.notificationInfo = Self.notificationInfo
        return subscription
    }
    
    var subscriptionID: String {
        return databaseZoneDescription + "Subscription"
    }
    
    static var notificationInfo: CKSubscription.NotificationInfo {
        let notification = CKSubscription.NotificationInfo()
        notification.shouldSendContentAvailable = true
        return notification
    }
    
    var notificationName: NSNotification.Name {
        return NSNotification.Name(rawValue: databaseZoneDescription)
    }
    
    private var previousZoneServerChangeTokenKey: String {
        return description + "ChangeTokenKey"
    }
    
    var previousZoneServerChangeToken: CKServerChangeToken? {
        get {
            guard let data = UserDefaults.standard.data(forKey: previousZoneServerChangeTokenKey) else {
                return nil
            }
            guard let token = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data) else { return nil }
            return token
        }
        set {
            guard let newValue = newValue else {
                UserDefaults.standard.set(nil, forKey: previousZoneServerChangeTokenKey)
                return
            }
            let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: previousZoneServerChangeTokenKey)
        }
    }
    
    private var previousSharedDatabaseServerChangeTokenKey: String {
        return databaseZoneDescription + "ChangeTokenKey"
    }
    
    var previousSharedDatabaseServerChangeToken: CKServerChangeToken? {
        get {
            guard let data = UserDefaults.standard.data(forKey: previousSharedDatabaseServerChangeTokenKey) else {
                return nil
            }
            guard let token = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data) else { return nil }
            return token
        }
        set {
            guard let newValue = newValue else {
                UserDefaults.standard.set(nil, forKey: previousSharedDatabaseServerChangeTokenKey)
                return
            }
            let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: previousSharedDatabaseServerChangeTokenKey)
        }
    }
    
    static var `public`: Self {
        return Self(databaseType: .public)
    }
    static var `private`: Self {
        return Self(databaseType: .private)
    }
    static var shared: Self {
        return Self(databaseType: .shared)
    }
}

enum DatabaseType: Int {
    case `public` = 1
    case `private` = 2
    case shared = 3
}

extension DatabaseType: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .public:
            return "public"
        case .private:
            return "private"
        case .shared:
            return "shared"
        }
    }
}
