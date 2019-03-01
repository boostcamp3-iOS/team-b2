//
//  Holiday+Extensions.swift
//  Bodabi
//
//  Created by jaehyeon lee on 24/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import CloudKit
import Foundation

extension Holiday: CloudManagedObject {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        setPrimitiveValue(Date(), forKey: "lastUpdate")
        prepareForCloudTask()
    }
    
    var recordType: String {
        return RemoteType.holiday
    }

    func prepareForCloudTask() {
        recordName = recordType + "." + UUID().uuidString
        let rawRecordID = CKRecord.ID(recordName: recordName!, zoneID: CloudZone.zoneID)
        recordID = try? NSKeyedArchiver.archivedData(withRootObject: rawRecordID, requiringSecureCoding: false)
    }
    
    func convertToRecord() -> CKRecord {
        guard let title = title,
        let date = date,
        let createdDate = createdDate,
        let image = image else { fatalError("converting to holiday record failed") }
        
        let holidayRecord = cloudRecord
        holidayRecord[RemoteHoliday.title] = title as NSString
        holidayRecord[RemoteHoliday.date] = date as NSDate
        holidayRecord[RemoteHoliday.createdDate] = createdDate as NSDate
        
        let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString + ".dat")
        do {
            try image.write(to: imageURL)
        } catch {
            print(error.localizedDescription)
        }
        let imageAsset = CKAsset(fileURL: imageURL)
        holidayRecord[RemoteHoliday.image] = imageAsset

        return holidayRecord
    }
    
    func updateWith(record: CKRecord, coreDataManager: CoreDataManager? = nil) {
        title = record[RemoteHoliday.title] as? String
        date = record[RemoteHoliday.date] as? Date
        createdDate = record[RemoteHoliday.createdDate] as? Date
        let imageAsset = record[RemoteHoliday.createdDate] as? CKAsset
        guard let imageURL = imageAsset?.fileURL else { return }
        image = try? Data(contentsOf: imageURL)
        
        recordName = record.recordID.recordName
        let archivedID = try? NSKeyedArchiver.archivedData(withRootObject: record.recordID, requiringSecureCoding: false)
        recordID = archivedID
    }
}
