//
//  CloudManager.swift
//  Bodabi
//
//  Created by Kim DongHwan on 08/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import CloudKit
import Foundation

final class CloudManager {
    
    private let container = CKContainer.default()
    private let privateDatabase = CKContainer.default().privateCloudDatabase
    public var zoneID: CKRecordZone.ID?
    
    init() {
        let zone = CKRecordZone(zoneName: "note-zone")
        zoneID = zone.zoneID
    }
    
    var iCloudAccountAvailable: Bool {
        get {
            return UserDefaults.standard.bool(forKey: DefaultsKey.iCloudAccountAvailable)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: DefaultsKey.iCloudAccountAvailable)
        }
    }
}
