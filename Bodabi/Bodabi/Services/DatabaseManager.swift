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
    let persistentContainer: NSPersistentContainer
    
    var friendFetchedResultsController: NSFetchedResultsController<Friend>?
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores {
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
}
