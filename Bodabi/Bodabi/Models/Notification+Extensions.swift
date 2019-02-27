//
//  Notification+Extensions.swift
//  Bodabi
//
//  Created by jaehyeon lee on 03/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import CloudKit
import Foundation

extension Notification: CloudManagedObject {

    public override func awakeFromInsert() {
        super.awakeFromInsert()
       
        setPrimitiveValue(false, forKey: "isRead")
        setPrimitiveValue(Date(), forKey: "lastUpdate")
        prepareForCloudTask()
    }

    // MARK: - Helper
    
    var sentence: String {
        if let name = self.event?.friend?.name,
            let title = self.event?.title?.addObjectSuffix(),
            let dday = self.event?.dday {
            if dday == 0 {
                return "오늘 \(name)님의 \(title) 축하해주세요!"
            } else if dday == 1 {
                return "내일 \(name)님의 \(title) 축하해주세요!"
            } else if dday > 0 {
                return "\(dday)일 뒤 \(name)님의 \(title) 축하해주세요!"
            } else {
                return "\(name)님의 \(title) 축하해주셨나요?"
            }
        }
        return "알림 정보를 불러올 수 없습니다"
    }
    
    var difference: Int {
        if let eventDate = self.event?.date {
            return self.date?.offsetFrom(date: eventDate) ?? UserDefaults.standard.integer(forKey: "defaultAlarmDday")
        }
        return UserDefaults.standard.integer(forKey: DefaultsKey.defaultAlarmDday)
    }
    
    var recordType: String {
        return RemoteType.notification
    }
    
    func prepareForCloudTask() {
        recordName = recordType + "." + UUID().uuidString
        let rawRecordID = CKRecord.ID(recordName: recordName!, zoneID: CloudZone.zoneID)
        recordID = try? NSKeyedArchiver.archivedData(withRootObject: rawRecordID, requiringSecureCoding: false)
    }
    
    func convertToRecord() -> CKRecord {
        guard let event = event,
            let date = date else { fatalError("converting to notification record failed") }
        
        let notificationRecord = cloudRecord
        notificationRecord[RemoteNotification.date] = date as NSDate
        notificationRecord[RemoteNotification.isHandled] = Int64(truncating: NSNumber(value: isHandled))
        notificationRecord[RemoteNotification.isRead] = Int64(truncating: NSNumber(value: isRead))
      
        let eventID = event.cloudRecordID
        notificationRecord[RemoteNotification.event] = CKRecord.Reference(recordID: eventID, action: .deleteSelf)

        return notificationRecord
    }
    
    func updateWith(record: CKRecord, coreDataManager: CoreDataManager?) {
        date = record[RemoteNotification.date] as? Date
        guard let isHandledNumber = record[RemoteNotification.isHandled] as? Int else { return }
        isRead = isHandledNumber == 1 ? true : false
        guard let isReadNumber = record[RemoteNotification.isRead] as? Int else { return }
        isRead = isReadNumber == 1 ? true : false
        
        if let eventReference = record[RemoteNotification.event] as? CKRecord.Reference {
            let eventRecordName = eventReference.recordID.recordName
            let predicate = NSPredicate(format: "recordName == %@", eventRecordName)
            var events: [Event] = []
            coreDataManager?.fetch(type: Event.self,
                                  predicate: predicate,
                                  sortDescriptor: nil,
                                  completion: { result in
                                    switch result {
                                    case let .failure(error):
                                        print(error.localizedDescription)
                                    case let .success(values):
                                        events = values
                                    }
            })
            if events.count > 0 {
                event = events.first
            } else {
                guard let event = self.event else { return }
                coreDataManager?.updateEvent(object: event, recordName: eventRecordName) {
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
