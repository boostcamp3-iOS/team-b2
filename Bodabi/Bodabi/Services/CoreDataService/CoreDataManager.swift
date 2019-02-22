//
//  CoreDataManager.swift
//  Bodabi
//
//  Created by jaehyeon lee on 01/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation
import CoreData



protocol CoreDataManagerClient {
    func setDatabaseManager(_ manager: CoreDataManager)
}

final class CoreDataManager {
    var container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        let context = container.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }
    
    init(modelName: String) {
        container = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        container.loadPersistentStores { storeDescription, error in
            if let _ = error {
                print(CoreDataError.loadFailed.localizedDescription)
            } else {
                completion?()
            }
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
                print(CoreDataError.batchDeletionFailed.localizedDescription)
            }
        }
    }
    
    func fetch<CoreDataObject: NSManagedObject>(type: CoreDataObject.Type, predicate: NSPredicate? = nil, sortDescriptor: NSSortDescriptor? = nil, completion: @escaping (Result<[CoreDataObject]>)->()) {
        
        let backgroundContext = container.newBackgroundContext()
    
        let request: NSFetchRequest<CoreDataObject> = CoreDataObject.fetchRequest() as! NSFetchRequest<CoreDataObject>
        
        if let predicate: NSPredicate = predicate {
            request.predicate = predicate
        }
        
        if let sortDescriptor: NSSortDescriptor = sortDescriptor {
            request.sortDescriptors = [sortDescriptor]
        }
        
        let complete: (Result) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: request) { asyncResult in
            guard let result = asyncResult.finalResult else {
                complete(.failure(CoreDataError.fetchFailed))
                return
            }
            
            let results: [CoreDataObject] = result.lazy
                .compactMap { $0.objectID }
                .compactMap { self.viewContext.object(with: $0) as? CoreDataObject }
            complete(.success(results))
        }
        
        do {
            try backgroundContext.execute(asyncFetchRequest)
        } catch {
            complete(.failure(CoreDataError.fetchFailed))
        }
    }
    
    func delete<CoreDataObject: NSManagedObject>(object: CoreDataObject, completion: @escaping (Error?)->()) {
        container.performBackgroundTask { backgroundContext in
            guard let object = backgroundContext.object(with: object.objectID) as? CoreDataObject else { return }
            do {
                backgroundContext.delete(object)
                try backgroundContext.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(CoreDataError.deletionFailed)
                }
            }
        }
    }
    
    func batchDelete(typeString: String, predicate: NSPredicate? = nil, completion: @escaping (Error?)->()) {
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
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(CoreDataError.batchDeletionFailed)
                }
            }
        }
    }
    
    func createFriend(name: String, tags: [String]? = nil, phoneNumber: String? = nil, completion: @escaping (Result<Friend>) -> ()) {
        container.performBackgroundTask { backgroundContext in
            let friend: Friend = Friend(context: backgroundContext)
            friend.name = name
            friend.tags = tags
            friend.phoneNumber = phoneNumber
            friend.favorite = false
            
            let complete: (Result) -> Void = { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
            do {
                try backgroundContext.save()
                guard let mainQueueFriend = self.viewContext.object(with: friend.objectID) as? Friend else {
                    complete(.failure(CoreDataError.creationFailed))
                    return
                }
                complete(.success(mainQueueFriend))
            } catch {
                complete(.failure(CoreDataError.creationFailed))
            }
        }
    }
        
    func createEvent(title: String, date: Date, friend: Friend, completion: @escaping (Event?, Error?) -> ()) {
        container.performBackgroundTask { backgroundContext in
            let event: Event = Event(context: backgroundContext)
            event.title = title
            event.date = date
            event.friend = friend
            event.favorite = false
            
            do {
                try backgroundContext.save()
                let mainQueueEvent = self.viewContext.object(with: event.objectID) as! Event
                completion(mainQueueEvent, nil)
            } catch {
                print("Event creation failed: \(error.localizedDescription)")
                completion(nil, CoreDataError.creationFailed)
            }
        }
    }
    
    func createHistory(holiday: String, item: String, isTaken: Bool, date: Date, friend: Friend, completion: @escaping (History?, Error?) -> ()) {
        container.performBackgroundTask { backgroundContext in
            let history: History = History(context: backgroundContext)
            history.holiday = holiday
            history.item = item
            history.isTaken = isTaken
            history.date = date
            history.friend = friend
            
            do {
                try backgroundContext.save()
                let mainQueueHistory = self.viewContext.object(with: history.objectID) as! History
                completion(mainQueueHistory, nil)
            } catch {
                completion(nil, CoreDataError.creationFailed)
            }
        }
    }
    
    func createHoliday(title: String, date: Date, image: Data? = nil, completion: @escaping (Holiday?, Error?) -> ()) {
        container.performBackgroundTask { backgroundContext in
            let holiday: Holiday = Holiday(context: backgroundContext)
            holiday.title = title
            holiday.date = date
            holiday.image = image
            holiday.createdDate = Date()
            
            do {
                try backgroundContext.save()
                let mainQueueHoliday = self.viewContext.object(with: holiday.objectID) as! Holiday
                completion(mainQueueHoliday, nil)
            } catch {
                completion(nil, CoreDataError.creationFailed)
            }
        }
    }
    
    func createNotification(event: Event, date: Date, completion: @escaping (Notification?, Error?) -> ()) {
        container.performBackgroundTask { backgroundContext in
            let notification: Notification = Notification(context: backgroundContext)
            let eventID = event.objectID
            notification.id = UUID().uuidString
            notification.date = date
            notification.isRead = false
            notification.isHandled = false
            
            do {
                try backgroundContext.save()
                let mainQueueNotification = self.viewContext.object(with: notification.objectID) as! Notification
                let mainQueueEvent = self.viewContext.object(with: eventID) as! Event
                mainQueueNotification.event = mainQueueEvent
                completion(mainQueueNotification, nil)
            } catch {
                completion(nil, CoreDataError.creationFailed)
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
    
    func updateHoliday(object: Holiday, title: String? = nil, date: Date? = nil, createdDate: Date? = nil, image: Data? = nil, completion: @escaping (Result<Holiday>)->()) {
        if title == nil, date == nil, createdDate == nil, image == nil {
            return
        }

        container.performBackgroundTask { backgroundContext in
            guard let holiday = backgroundContext.object(with: object.objectID) as? Holiday else { return }
            if let title = title { holiday.title = title }
            if let date = date { holiday.date = date }
            if let createdDate = createdDate { holiday.createdDate = createdDate }
            if let image = image { holiday.image = image }
            let complete: (Result) -> Void = { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
            do {
                try backgroundContext.save()
                    guard let updatedHoliday = self.viewContext.object(with: holiday.objectID) as? Holiday else { return }
                    complete(.success(updatedHoliday))
            } catch {
                complete(.failure(CoreDataError.creationFailed))
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

    func batchUpdate(typeString: String, predicate: NSPredicate? = nil, updateDictionary: [AnyHashable: Any], completion: @escaping (Result<History>)->()) {
        container.performBackgroundTask { backgroundContext in
            let updateRequest = NSBatchUpdateRequest(entityName: typeString)
            guard let predicate = predicate else { return }
            updateRequest.predicate = predicate
            updateRequest.propertiesToUpdate = updateDictionary
            updateRequest.resultType = .updatedObjectIDsResultType
        
            do {
                let result = try backgroundContext.execute(updateRequest) as? NSBatchUpdateResult
                guard let objectIDs = result?.result as? [NSManagedObjectID] else { return }
                let changes = [NSUpdatedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.viewContext])
            } catch {
                DispatchQueue.main.async{
                    completion(.failure(CoreDataError.batchUpdateFailed))
                }
            }
        }
    }
}

protocol CoreDataManagerProtocol {
    var container: NSPersistentContainer { get }
    var viewContext: NSManagedObjectContext { get }
    func load(completion: (() -> Void)?)
    func deleteAll()
    func fetch<CoreDataObject: NSManagedObject>(type: CoreDataObject.Type, predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?, completion: @escaping (Result<[CoreDataObject]>)->())
    func delete<CoreDataObject: NSManagedObject>(object: CoreDataObject, completion: @escaping (Error?)->())
    func batchDelete(typeString: String, predicate: NSPredicate?, completion: @escaping (Error?)->())
    func createFriend(name: String, tags: [String], phoneNumber: String?, completion: @escaping (Result<Friend>) -> ())
    func createEvent(title: String, date: Date, friend: Friend, completion: @escaping (Event?, Error?) -> ())
    func createHistory(holiday: String, item: String, isTaken: Bool, date: Date, friend: Friend, completion: @escaping (History?, Error?) -> ())
    func createHoliday(title: String, date: Date, image: Data?, completion: @escaping (Holiday?, Error?) -> ())
    func createNotification(event: Event, date: Date, completion: @escaping (Notification?, Error?) -> ())
    func updateFriend(object: Friend, name: String?, tags: [String]?, favorite: Bool?, phoneNumber: String?)
    func updateEvent(object: Event, title: String?, date: Date?, favorite: Bool?, friend: Friend?)
    func updateHistory(object: History, holiday: String?, item: String?, date: Date?, isTaken: Bool?, friend: Friend?)
    func updateHoliday(object: Holiday, title: String?, date: Date?, createdDate: Date?, image: Data?, completion: @escaping (Result<Holiday>)->())
    func updateNotification(object: Notification, event: Event?, date: Date?, isRead: Bool?, isHandled: Bool?)
    func batchUpdate(typeString: String, predicate: NSPredicate?, updateDictionary: [AnyHashable: Any], completion: @escaping (Result<History>)->())
}
