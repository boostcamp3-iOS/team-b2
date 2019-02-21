//
//  MockCoreDataManager.swift
//  BodabiTests
//
//  Created by 이혜진 on 2019. 2. 21..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

@testable import Bodabi
//import Foundation
import CoreData

typealias FriendType = (name: String, tags: [String], phone: String)

final class MockCoreDataManager: CoreDataManagerProtocol {
    
    static let tuples: [FriendType] = [
        ("이재현", ["연락처"], "010-7929-9390"),
        ("이혜진", ["연락처"], "010-3434-1244"),
        ("김동환", ["연락처"], "010-2748-9487"),
        ("김힘찬나래", ["연락처"], "010-1234-5345"),
        ("정Amy", ["연락처"], "010-792-9939"),
        ("김하늘", ["연락처"], "010-404-3119"),
        ("fdjhsahjklf", ["연락처"], "010-7929-9390"),
        ("김동환", ["연락처"], "010-2748-9487")
    ]
    
    
//    var fetchedResult: Result<NSManagedObject> {
//
//    }
    
    var fetchedArrayResult: Result<[NSManagedObject]> {
        return Result.failure(error!)
    }
    
    var error : Error?
    
    var friend: Friend?
    var holiday: Holiday?
    var history: History?
    var event: Event?
    var notification: Bodabi.Notification?
//
//
//    var viewContext: NSManagedObjectContext {
//        return container.viewContext
//    }
//
//    func load(completion: (() -> Void)?) {
//        container.loadPersistentStores { storeDescription, error in
//            if let _ = error {
//                print(CoreDataError.loadFailed.localizedDescription)
//            } else {
//                completion?()
//            }
//        }
//
//        print("Library Path: ", FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last ?? "Not Found!")
//    }
    
    func deleteAll() {}
    
    func fetch<CoreDataObject>(type: CoreDataObject.Type, predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?, completion: @escaping (Result<[CoreDataObject]>) -> ()) where CoreDataObject : NSManagedObject {
        guard let fetchedArrayResult = fetchedArrayResult as? Result<[CoreDataObject]> else { return }
        completion(fetchedArrayResult)
    }
    
    func delete<CoreDataObject>(object: CoreDataObject, completion: @escaping (Error?) -> ()) where CoreDataObject : NSManagedObject {
        completion(error)
    }
    
    func batchDelete(typeString: String, predicate: NSPredicate?, completion: @escaping (Error?) -> ()) {
        completion(error)
    }
    
    func createFriend(name: String, tags: [String], phoneNumber: String?, completion: @escaping (Result<Friend>) -> ()) {
//        let friend: FriendType = (name: name, tags: tags, phone: phoneNumber ?? "")
//        completion(.success(friend))
    }
    
    func createEvent(title: String, date: Date, friend: Friend, completion: @escaping (Event?, Error?) -> ()) {
        completion(event, error)
    }
    
    func createHistory(holiday: String, item: String, isTaken: Bool, date: Date, friend: Friend, completion: @escaping (History?, Error?) -> ()) {
        completion(history, error)
    }
    
    func createHoliday(title: String, date: Date, image: Data?, completion: @escaping (Holiday?, Error?) -> ()) {
        completion(holiday, error)
    }
    
    func createNotification(event: Event, date: Date, completion: @escaping (Bodabi.Notification?, Error?) -> ()) {
        completion(notification, error)
    }
    
    func updateFriend(object: Friend, name: String?, tags: [String]?, favorite: Bool?, phoneNumber: String?) { }
    
    func updateEvent(object: Event, title: String?, date: Date?, favorite: Bool?, friend: Friend?) { }
    
    func updateHistory(object: History, holiday: String?, item: String?, date: Date?, isTaken: Bool?, friend: Friend?) { }
    
    func updateHoliday(object: Holiday, title: String?, date: Date?, createdDate: Date?, image: Data?, completion: @escaping (Result<Holiday>) -> ()) {
//        completion(fetchedResult as! Result<Holiday>)
    }
    
    func updateNotification(object: Bodabi.Notification, event: Event?, date: Date?, isRead: Bool?, isHandled: Bool?) { }
    
    func batchUpdate(typeString: String, predicate: NSPredicate?, updateDictionary: [AnyHashable : Any], completion: @escaping (Result<History>) -> ()) {
//        completion(fetchedResult as! Result<History>)
    }
    
    
}
