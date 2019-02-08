//
//  InputManager.swift
//  Bodabi
//
//  Created by Kim DongHwan on 07/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation
import CoreData

struct InputManager {
    
    static func write(context: NSManagedObjectContext, entryRoute: EntryRoute, data: InputData) {
        switch entryRoute {
        case .addHolidayAtHome:
            let holiday: Holiday = Holiday(context: context)
            holiday.title = data.holiday
            holiday.date = data.date
        case .addUpcomingEventAtHome:
            let event: Event = Event(context: context)
            if let friend = getFriend(context: context, name: data.name ?? "") {
                event.friend = friend
            }
            event.friend?.name = data.name
            event.title = data.holiday
            event.date = data.date
        case .addHistoryAtHoliday,
             .addHistoryAtFriendHistory:
            let history: History = History(context: context)
            if let friend = getFriend(context: context, name: data.name ?? "") {
                history.friend = friend
            }
            history.item = data.item?.value
            history.holiday = data.holiday
            history.date = data.date
            history.isTaken = entryRoute == .addHistoryAtHoliday ? true : false
        case .addFriendAtFriends:
            let friend: Friend = Friend(context: context)
            friend.name = data.name
        }
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // 추후에 tags 적용
    static private func checkDuplication(context: NSManagedObjectContext, name: String) -> Bool {
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
    static private func getFriend(context: NSManagedObjectContext, name: String) -> Friend? {
        // 새로운 friend를 만들어야 하는지 기존의 friend를 fetch해오는지 중복체크를 해서
        if !checkDuplication(context: context, name: name) {
            let friend: Friend = Friend(context: context)
            friend.name = name
            return friend
        } else {
            let request: NSFetchRequest<Friend> = Friend.fetchRequest()
            let predicate = NSPredicate(format: "name = %@", name)
            request.predicate = predicate
            
            if let result = try? context.fetch(request) {
                return result.first
            } else {
                return nil
            }
            
        }
    }
}
