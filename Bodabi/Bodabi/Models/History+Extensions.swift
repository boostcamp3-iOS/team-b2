//
//  History+Extensions.swift
//  Bodabi
//
//  Created by jaehyeon lee on 03/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import CloudKit
import Foundation

extension History: CloudManagedObject {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        setPrimitiveValue(Date(), forKey: "lastUpdate")
        prepareForCloudTask()
    }
    
    // MARK: - Helper
    
    var giveSentence: String {
        if let item = self.item, let cash = Int(item) {
            let formattedCash = String(cash).insertComma()
            return "\(self.friend?.name ?? "")님께 \(self.holiday?.addForSuffix() ?? "") \(formattedCash ?? "")원을 전달했습니다"
        } else {
            return "\(self.friend?.name ?? "")님께 \(self.holiday?.addForSuffix() ?? "") \(self.item?.addObjectSuffix() ?? "") 전달했습니다"
        }
    }
    var takeSentence: String {
        if let item = self.item, let cash = Int(item) {
            let formattedCash = String(cash).insertComma()
            return "\(self.friend?.name ?? "")님께서 \(self.holiday?.addForSuffix() ?? "") \(formattedCash ?? "")원을 전달해주셨습니다"
        } else {
            return "\(self.friend?.name ?? "")님께서 \(self.holiday?.addForSuffix() ?? "") \(self.item?.addObjectSuffix() ?? "") 전달해주셨습니다"
        }
    }
    
    var recordType: String {
        return RemoteType.history
    }
    
    func prepareForCloudTask() {
        recordName = recordType + "." + UUID().uuidString
        let rawRecordID = CKRecord.ID(recordName: recordName!, zoneID: CloudZone.zoneID)
        recordID = try? NSKeyedArchiver.archivedData(withRootObject: rawRecordID, requiringSecureCoding: false)
    }
    
    func convertToRecord() -> CKRecord {
        guard let holiday = holiday,
            let date = date,
            let item = item,
            let friend = friend else { fatalError("converting to event record failed") }
        
        let historyRecord = cloudRecord
        historyRecord[RemoteHistory.holiday] = holiday as NSString
        historyRecord[RemoteHistory.item] = item as NSString
        historyRecord[RemoteHistory.date] = date as NSDate
        historyRecord[RemoteHistory.isTaken] = Int64(truncating: NSNumber(value: isTaken))
        
        let friendID = friend.cloudRecordID
        historyRecord[RemoteHistory.friend] = CKRecord.Reference(recordID: friendID, action: .deleteSelf)

        return historyRecord
    }
    
    func updateWith(record: CKRecord, coreDataManager: CoreDataManager?) {
        holiday = record[RemoteHistory.holiday] as? String
        date = record[RemoteHistory.date] as? Date
        item = record[RemoteHistory.item] as? String
        guard let isTakenNumer = record[RemoteHistory.isTaken] as? Int else { return }
        isTaken = isTakenNumer == 1 ? true : false
        
        if let friendReference = record[RemoteHistory.friend] as? CKRecord.Reference {
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
            } else {
                guard let friend = self.friend else { return }
                coreDataManager?.updateFriend(object: friend, recordName: friendRecordName) {
                    switch $0 {
                    case let .failure(error):
                        print(error.localizedDescription)
                    case .success:
                        break
                    }
                }
            }
        }
        
        recordName = record.recordID.recordName
        let archivedID = try? NSKeyedArchiver.archivedData(withRootObject: record.recordID, requiringSecureCoding: false)
        recordID = archivedID
    }
}
