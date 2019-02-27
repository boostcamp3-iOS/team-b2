//
//  CloudKitManagedObject.swift
//  Bodabi
//
//  Created by jaehyeon lee on 24/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import CloudKit
import Foundation

protocol CloudManagedObject {
    var recordID: Data? { get set }
    var recordName: String? { get set }
    var recordType: String { get }
    var lastUpdate: Date? { get set }
    
    func convertToRecord() -> CKRecord
    func updateWith(record: CKRecord, coreDataManager: CoreDataManager?)
}

extension CloudManagedObject {
    var cloudRecord: CKRecord {
        return CKRecord(recordType: recordType, recordID: cloudRecordID)
    }
    var cloudRecordID: CKRecord.ID {
        guard let recordID = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [CKRecord.ID.self], from: recordID!) else { return CKRecord.ID() }
        return recordID as! CKRecord.ID
    }
}
