//
//  CloudManager.swift
//  Bodabi
//
//  Created by Kim DongHwan on 08/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation
import CloudKit

struct CloudManager {
    
    func save() {
        let friendRecord = CKRecord(recordType: "Friend")
        
        friendRecord["name"] = "김동환" as NSString
        
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        
        privateDatabase.save(friendRecord) { (record, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            print(record)
        }
    }
}
