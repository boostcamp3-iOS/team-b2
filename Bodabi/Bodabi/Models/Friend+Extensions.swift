//
//  Friend+Extensions.swift
//  Bodabi
//
//  Created by jaehyeon lee on 24/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import CloudKit
import Foundation

extension Friend: CloudManagedObject {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        setPrimitiveValue(Date(), forKey: "lastUpdate")
        prepareForCloudTask()
    }
    
    var recordType: String {
        return RemoteType.friend
    }
    
    func prepareForCloudTask() {
        recordName = recordType + "." + UUID().uuidString
        let rawRecordID = CKRecord.ID(recordName: recordName!, zoneID: CloudZone.zoneID)
        recordID = try? NSKeyedArchiver.archivedData(withRootObject: rawRecordID, requiringSecureCoding: false)
    }
    
    func convertToRecord() -> CKRecord {
        guard let name = name else { fatalError("converting to friend record failed") }
        
        let friendRecord = cloudRecord
        friendRecord[RemoteFriend.name] = name as NSString
        friendRecord[RemoteFriend.favorite] = Int64(truncating: NSNumber(value: favorite))
        if phoneNumber != nil, let phoneNumberValue = phoneNumber {
            friendRecord[RemoteFriend.phoneNumber] = phoneNumberValue as NSString
        }
        if tags != nil, let tagsValue = tags {
            friendRecord[RemoteFriend.tags] = tagsValue as [NSString]
        }
        
        return friendRecord
    }
    
    func updateWith(record: CKRecord, coreDataManager: CoreDataManager?) {
        name = record[RemoteFriend.name] as? String
        phoneNumber = record[RemoteFriend.phoneNumber] as? String
        tags = record[RemoteFriend.tags] as? [String]
        guard let favoriteNumber = record[RemoteFriend.favorite] as? Int else { return }
        favorite = favoriteNumber == 1 ? true : false
        
        recordName = record.recordID.recordName
        let archivedID = try? NSKeyedArchiver.archivedData(withRootObject: record.recordID, requiringSecureCoding: false)
        recordID = archivedID
    }
}
