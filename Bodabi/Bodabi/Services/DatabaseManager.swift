//
//  DatabaseManager.swift
//  Bodabi
//
//  Created by jaehyeon lee on 01/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation
import CoreData

protocol DatabaseManagerClient {
    func setDatabaseManager(_ manager: DatabaseManager)
}

class DatabaseManager {
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        let context = container.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }
    
    init(modelName: String) {
        container = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        container.loadPersistentStores {
            storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            completion?()
        }

        print("Library Path: ", FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last ?? "Not Found!")
    }
    
    func deleteAll(){
        let friendfetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
        let historyfetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        let holidayfetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Holiday")
        let eventfetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        let notificationfetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notification")
        let requests = [friendfetchRequest, historyfetchRequest, holidayfetchRequest, eventfetchRequest, notificationfetchRequest]
        
        for request in requests {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            do {
                try viewContext.execute(deleteRequest)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func fetch<CoreDataObject: NSManagedObject>(type: CoreDataObject.Type, predicate: NSPredicate? = nil, sortDescriptor: NSSortDescriptor? = nil, completion: @escaping ([CoreDataObject])->()) {
        
        let backgroundContext = container.newBackgroundContext()
        
        let request: NSFetchRequest<CoreDataObject> = CoreDataObject.fetchRequest() as! NSFetchRequest<CoreDataObject>
        if let predicate: NSPredicate = predicate {
            request.predicate = predicate
        }
        if let sortDescriptor: NSSortDescriptor = sortDescriptor {
            request.sortDescriptors = [sortDescriptor]
        }
        
        let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: request) { asyncResult in
            guard let result = asyncResult.finalResult else { return }
            DispatchQueue.main.async {
                let results: [CoreDataObject] = result.lazy
                    .compactMap { $0.objectID }
                    .compactMap { self.viewContext.object(with: $0) as? CoreDataObject }
                completion(results)
            }
        }
        
        do {
            try backgroundContext.execute(asyncFetchRequest)
        } catch {
            print("Core data fetch failed: \(error.localizedDescription)")
        }
    }
    
    func delete<CoreDataObject: NSManagedObject>(object: CoreDataObject) {
        container.performBackgroundTask { backgroundContext in
            guard let object = backgroundContext.object(with: object.objectID) as? CoreDataObject else { return }
            do {
                backgroundContext.delete(object)
                try backgroundContext.save()
            } catch {
                print("Core data deletion failed: \(error.localizedDescription)")
            }
        }
    }
    
    func batchDelete(typeString: String, predicate: NSPredicate? = nil) {
        container.performBackgroundTask { backgroundContext in
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: typeString)
            if let predicate = predicate {
                request.predicate = predicate
            }
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            deleteRequest.resultType = .resultTypeObjectIDs
            
            do {
                let result = try backgroundContext.execute(deleteRequest) as? NSBatchDeleteResult
                guard let objectIDs = result?.result as? [NSManagedObjectID] else { return }
                let changes = [NSDeletedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.viewContext])
            } catch {
                print("Core data batch deletion failed: \(error.localizedDescription)")
            }
        }
    }
    
    func createFriend(name: String, tags: [String]? = nil, phoneNumber: String? = nil, completion: @escaping (Friend) -> ()) {
        container.performBackgroundTask { backgroundContext in
            let friend: Friend = Friend(context: backgroundContext)
            friend.name = name
            friend.tags = tags
            friend.phoneNumber = phoneNumber
            friend.favorite = false
            
            do {
                try backgroundContext.save()
                DispatchQueue.main.async {
                    let mainQueueFriend = self.viewContext.object(with: friend.objectID) as! Friend
                    completion(mainQueueFriend)
                }
            } catch {
                print("Friend creation failed: \(error.localizedDescription)")
            }
        }
    }
        
    func createEvent(title: String, date: Date, friend: Friend, completion: @escaping (Event) -> ()) {
        container.performBackgroundTask { backgroundContext in
            let event: Event = Event(context: backgroundContext)
            event.title = title
            event.date = date
            event.friend = friend
            event.favorite = false
            
            do {
                try backgroundContext.save()
                DispatchQueue.main.async {
                    let mainQueueEvent = self.viewContext.object(with: event.objectID) as! Event
                    completion(mainQueueEvent)
                }
            } catch {
                print("Event creation failed: \(error.localizedDescription)")
            }
        }
    }
    
    func createHistory(holiday: String, item: String, isTaken: Bool, date: Date, friend: Friend, completion: @escaping (History) -> ()) {
        container.performBackgroundTask { backgroundContext in
            let history: History = History(context: backgroundContext)
            history.holiday = holiday
            history.item = item
            history.isTaken = isTaken
            history.date = date
            history.friend = friend
            
            do {
                try backgroundContext.save()
                DispatchQueue.main.async {
                    let mainQueueHistory = self.viewContext.object(with: history.objectID) as! History
                    completion(mainQueueHistory)
                }
            } catch {
                print("History creation failed: \(error.localizedDescription)")
            }
        }
    }
    
    func createHoliday(title: String, date: Date, image: Data? = nil, completion: @escaping (Holiday) -> ()) {
        container.performBackgroundTask { backgroundContext in
            let holiday: Holiday = Holiday(context: backgroundContext)
            holiday.title = title
            holiday.date = date
            holiday.image = image
            holiday.createdDate = Date()
            
            do {
                try backgroundContext.save()
                DispatchQueue.main.async {
                    let mainQueueHoliday = self.viewContext.object(with: holiday.objectID) as! Holiday
                    completion(mainQueueHoliday)
                }
            } catch {
                print("Holiday creation failed: \(error.localizedDescription)")
            }
        }
    }
    
    func createNotification(event: Event, date: Date, completion: @escaping (Notification) -> ()) {
        container.performBackgroundTask { backgroundContext in
            let notification: Notification = Notification(context: backgroundContext)
            let eventID = event.objectID
            notification.id = UUID().uuidString
            notification.date = date
            notification.isRead = false
            notification.isHandled = false
            
            do {
                try backgroundContext.save()
                DispatchQueue.main.async {
                    let mainQueueNotification = self.viewContext.object(with: notification.objectID) as! Notification
                    let mainQueueEvent = self.viewContext.object(with: eventID) as! Event
                    mainQueueNotification.event = mainQueueEvent
                    completion(mainQueueNotification)
                }
            } catch {
                print("Notification creation failed: \(error.localizedDescription)")
            }
        }
    }
    
    func updateFriend(object: Friend, name: String? = nil, tags: [String]? = nil, favorite: Bool? = nil, phoneNumber: String? = nil) {
        if name == nil, tags == nil, favorite == nil, phoneNumber == nil {
            return
        }
        container.performBackgroundTask { backgroundContext in
            let friend = backgroundContext.object(with: object.objectID) as? Friend
            if let name = name { friend?.name = name }
            if let tags = tags { friend?.tags = tags }
            if let favorite = favorite { friend?.favorite = favorite }
            if let phoneNumber = phoneNumber { friend?.phoneNumber = phoneNumber }
            
            do {
                try backgroundContext.save()
            } catch {
                print("Notification creation failed: \(error.localizedDescription)")
            }
        }
    }
    
    func updateEvent(object: Event, title: String? = nil, date: Date? = nil, favorite: Bool? = nil, friend: Friend? = nil) {
        if title == nil, date == nil, favorite == nil, friend == nil {
            return
        }
        container.performBackgroundTask { backgroundContext in
            let event = backgroundContext.object(with: object.objectID) as? Event
            if let title = title { event?.title = title }
            if let date = date { event?.date = date }
            if let favorite = favorite { event?.favorite = favorite }
            if let friend = friend {
                event?.friend = backgroundContext.object(with: friend.objectID) as? Friend
            }
            
            do {
                try backgroundContext.save()
            } catch {
                print("Notification creation failed: \(error.localizedDescription)")
            }
        }
    }
    
    func updateHistory(object: History, holiday: String? = nil, item: String? = nil, date: Date? = nil, isTaken: Bool? = nil, friend: Friend? = nil) {
        if holiday == nil, item == nil, date == nil, isTaken == nil, friend == nil {
            return
        }
        container.performBackgroundTask { backgroundContext in
            let history = backgroundContext.object(with: object.objectID) as? History
            if let holiday = holiday { history?.holiday = holiday }
            if let item = item { history?.item = item }
            if let date = date { history?.date = date }
            if let isTaken = isTaken { history?.isTaken = isTaken }
            if let friend = friend {
                history?.friend = backgroundContext.object(with: friend.objectID) as? Friend
            }
            
            do {
                try backgroundContext.save()
            } catch {
                print("Notification creation failed: \(error.localizedDescription)")
            }
        }
    }
    
    func updateHoliday(object: Holiday, title: String? = nil, date: Date? = nil, createdDate: Date? = nil, image: Data? = nil) {
        if title == nil, date == nil, createdDate == nil, image == nil {
            return
        }
        container.performBackgroundTask { backgroundContext in
            let holiday = backgroundContext.object(with: object.objectID) as? Holiday
            if let title = title { holiday?.title = title }
            if let date = date { holiday?.date = date }
            if let createdDate = createdDate { holiday?.createdDate = createdDate }
            if let image = image { holiday?.image = image }
            
            do {
                try backgroundContext.save()
            } catch {
                print("Notification creation failed: \(error.localizedDescription)")
            }
        }
    }
    
    func updateNotification(object: Notification, event: Event? = nil, date: Date? = nil, isRead: Bool? = nil, isHandled: Bool? = nil) {
        if event == nil, date == nil, isRead == nil, isHandled == nil {
            return
        }
        container.performBackgroundTask { backgroundContext in
            let notification = backgroundContext.object(with: object.objectID) as? Notification
            if let event = event {
                notification?.event = backgroundContext.object(with: event.objectID) as? Event
            }
            if let date = date { notification?.date = date }
            if let isRead = isRead { notification?.isRead = isRead }
            if let isHandled = isHandled { notification?.isHandled = isHandled }
            
            do {
                try backgroundContext.save()
                
                
            } catch {
                print("Notification creation failed: \(error.localizedDescription)")
            }
        }
    }
    
    func batchUpdateHistory(typeString: String, predicate: NSPredicate? = nil) {
        container.performBackgroundTask { backgroundContext in
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: typeString)
            if let predicate = predicate {
                request.predicate = predicate
            }
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            deleteRequest.resultType = .resultTypeObjectIDs
            
            do {
                let result = try backgroundContext.execute(deleteRequest) as? NSBatchDeleteResult
                guard let objectIDs = result?.result as? [NSManagedObjectID] else { return }
                let changes = [NSDeletedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.viewContext])
            } catch {
                print("Core data batch deletion failed: \(error.localizedDescription)")
            }
        }
    }
}

