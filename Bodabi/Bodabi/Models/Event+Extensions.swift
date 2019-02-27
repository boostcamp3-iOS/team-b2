//
//  Event+Extensions.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 8..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import CloudKit
import Foundation

extension Event: CloudManagedObject {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        setPrimitiveValue(Date(), forKey: "lastUpdate")
        prepareForCloudTask()
    }
    
    // MARK: - Helper
    
    var dday: Int {
        if let eventDate = self.date {
            let currentDate: Date = Date()
            let dday: Int = eventDate.offsetFrom(date: currentDate)
            return dday
        }
        return 0
    }
    
    var recordType: String {
        return RemoteType.event
    }
    
    func prepareForCloudTask() {
        recordName = recordType + "." + UUID().uuidString
        let rawRecordID = CKRecord.ID(recordName: recordName!, zoneID: CloudZone.zoneID)
        recordID = try? NSKeyedArchiver.archivedData(withRootObject: rawRecordID, requiringSecureCoding: false)
    }
    
    func convertToRecord() -> CKRecord {
        guard let title = title,
            let date = date,
            let friend = friend else { fatalError("converting to event record failed") }
        
        let eventRecord = cloudRecord
        eventRecord[RemoteEvent.title] = title as NSString
        eventRecord[RemoteEvent.date] = date as NSDate
        eventRecord[RemoteEvent.favorite] = Int64(truncating: NSNumber(value: favorite))
        
        let friendID = friend.cloudRecordID
        eventRecord[RemoteEvent.friend] = CKRecord.Reference(recordID: friendID, action: .deleteSelf)
        
        return eventRecord
    }
    
    func updateWith(record: CKRecord, coreDataManager: CoreDataManager?) {
        title = record[RemoteEvent.title] as? String
        date = record[RemoteEvent.date] as? Date
        guard let favoriteNumber = record[RemoteEvent.favorite] as? Int else { return }
        favorite = favoriteNumber == 1 ? true : false
        
        if let friendReference = record[RemoteEvent.friend] as? CKRecord.Reference {
            let friendRecordName = friendReference.recordID.recordName
            let predicate = NSPredicate(format: "recordName == %@", friendRecordName)
            var friends: [Friend] = []
            coreDataManager?.fetch(type: Friend.self,
                                  predicate: predicate,
                                  sortDescriptor: nil,
                                  completion: { result in
                switch result {
                case let .failure(error):
                    print(error.localizedDescription)
                case let .success(values):
                    friends = values
                }
            })
            if friends.count > 0 {
                friend = friends.first
            }
        }
        
        recordName = record.recordID.recordName
        let archivedID = try? NSKeyedArchiver.archivedData(withRootObject: record.recordID, requiringSecureCoding: false)
        recordID = archivedID
    }
}

