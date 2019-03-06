//
//  InputManager.swift
//  Bodabi
//
//  Created by Kim DongHwan on 07/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import CoreData
import UIKit

struct InputManager {
    var entryType: EntryType
    var inputData: InputData
    var inputType: InputType
    
    init(entryType: EntryType, inputData: InputData, inputType: InputType) {
        self.entryType = entryType
        self.inputData = inputData
        self.inputType = inputType
    }
    
    init(entryType: EntryType, inputType: InputType) {
        let inputData: InputData = InputData()
        self.init(entryType: entryType, inputData: inputData, inputType: inputType)
    }
    
    func createViewController(type: InputType) -> UIViewController {
        return UIStoryboard(name: "Input", bundle: nil).instantiateViewController(withIdentifier: type.identifier)
    }
    
    static func write(context: NSManagedObjectContext, entryRoute: EntryRoute, data: InputData) {
        switch entryRoute {
        case .addHolidayAtHome:
            let holiday: Holiday = Holiday(context: context)
            if let relationText = data.relation, let holidayText = data.holiday {
                holiday.title = relationText + "의 " + holidayText
            }
        
            holiday.date = data.date
            holiday.createdDate = Date()
            
            holiday.image = DefaultHolidayType.parse(with: holiday.title).holidayImage
                .resize(scale: 0.1)?.jpegData(compressionQuality: 1.0)
            
        case .addUpcomingEventAtHome:
            let event: Event = Event(context: context)
            let friend = getFriend(context: context, data: data)
            
            event.friend = friend
            event.favorite = false
            event.friend?.name = data.name
            event.friend?.tags = data.tags != nil ? data.tags : event.friend?.tags
            event.title = data.holiday
            event.date = data.date
            generateNotifications(of: event, context: context)
        case .addHistoryAtHoliday,
             .addHistoryAtFriendHistory:
            let history: History = History(context: context)
            let friend = getFriend(context: context, data: data)
            history.friend = friend
            history.item = data.item?.value
            history.holiday = data.holiday
            history.date = data.date
            history.isTaken = entryRoute == .addHistoryAtHoliday ? true : false
        case .addFriendAtFriends:
            if data.isNewData {
                let friend: Friend = Friend(context: context)
                friend.name = data.name
                friend.tags = data.tags != nil ? data.tags : friend.tags
                friend.favorite = false
            }
        }
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // 추후에 tags 적용
    static private func checkDuplication(context: NSManagedObjectContext, name: String, tags: [String]) -> Bool {
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        if let result = try? context.fetch(request) {
            for friend in result {
                if friend.name == name {
                    return true
                }
            }
            return false
        }
        return false
    }
    
    // friend를 가져오는 메소드
    static private func getFriend(context: NSManagedObjectContext, name: String, tags: [String]) -> Friend? {
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        let predicate = NSPredicate(format: "name = %@", name)
        request.predicate = predicate
        
        var searchedFriend: Friend?
        
        if let result = try? context.fetch(request) {
            // Fix tags 식별해서 하나의 친구만 가져오기
            result.forEach { (friend) in
                if let friendTags = friend.tags {
                    if isSame(tags, with: friendTags) {
                        searchedFriend = friend
                        return
                    }
                } else if friend.tags == nil, tags.count == 0 {
                    searchedFriend = friend
                    return
                }
            }
            
            return searchedFriend
        } else {
            return nil
        }
    }
    
    static private func getFriend(context: NSManagedObjectContext, data: InputData) -> Friend? {
        if data.isNewData {
            let friend: Friend = Friend(context: context)
            friend.name = data.name
            friend.tags = data.tags != nil ? data.tags : friend.tags
            friend.favorite = false
            return friend
        }
        
        if let friend: Friend = getFriend(context: context, name: data.name ?? "", tags: data.tags ?? []) {
            return friend
        } else {
            return nil
        }
    }
    
    static private func isSame(_ newTags: [String], with friendTags: [String]) -> Bool {
        guard newTags.count == friendTags.count else {
            return false
        }
        
        let sortNewTags = newTags.sorted()
        let sortFriendTags = friendTags.sorted()
        
        for i in 0..<sortNewTags.count {
            if sortNewTags[i] != sortFriendTags[i] {
                return false
            }
        }
        
        return true
    }
    
    static private func generateNotifications(of event: Event, context: NSManagedObjectContext){
            let notification: Notification = Notification(context: context)
            let defaultDday = UserDefaults.standard.integer(forKey: DefaultsKey.defaultAlarmDday)
            let defaultHour = UserDefaults.standard.integer(forKey: DefaultsKey.defaultAlarmHour)
            let defaultMinutes = UserDefaults.standard.integer(forKey: DefaultsKey.defaultAlarmMinutes)
            notification.id = UUID().uuidString
            notification.event = event
            notification.date =  event.date?.addingTimeInterval(TimeInterval(exactly: (defaultDday + 1) * Int.day * -1 + defaultHour * Int.hour + defaultMinutes * Int.minute) ?? 0)
            NotificationSchedular.create(notification: notification,
                                         hour: defaultHour,
                                         minute: defaultMinutes)
    }
}



