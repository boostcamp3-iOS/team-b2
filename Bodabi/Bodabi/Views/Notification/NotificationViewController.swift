//
//  NotificationViewController.swift
//  Bodabi
//
//  Created by jaehyeon lee on 27/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit
import CoreData

class NotificationViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    // MARK: - Property
    
    private var databaseManager: DatabaseManager!
    private var fetchedResultsController: NSFetchedResultsController<Notification>?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initFetchedResultsController()
        initTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initNavigationBar()
    }
    
    // MARK: - Initialization
    
    private func initTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        let cell = NotificationViewCell.self
        tableView.register(cell)
        tableView.tableFooterView = UIView()
    }
    
    private func initNavigationBar(){
        navigationController?.navigationBar.clear()
    }
    
    private func initFetchedResultsController() {
        let fetchResult: NSFetchRequest<Notification> = Notification.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let deliveredPredicate = NSPredicate(format: "isHandled = %@", NSNumber(value: true))
        let datePredicate = NSPredicate(format: "date > %@", NSDate())
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [deliveredPredicate, datePredicate])
        fetchResult.sortDescriptors = [sortDescriptor]
        fetchResult.predicate = compoundPredicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchResult, managedObjectContext: (databaseManager?.viewContext)!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Method
    
    private func updateNotificationRead(indexPath: IndexPath) {
        if let notification = fetchedResultsController?.object(at: indexPath) {
            databaseManager.updateNotification(object: notification, isRead: true) {
                switch $0 {
                case let .failure(error):
                    print(error.localizedDescription)
                case .success:
                    break
                }
            }
        }
    }
    
    private func setEmptyView() {
        let isEmpty = tableView.numberOfRows(inSection: 0) == 0  ? true : false
        emptyView.isHidden = !isEmpty
    }
}

// MARK: - UITableViewDataSource

extension NotificationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?.first?.numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        setEmptyView()
        let cell = tableView.dequeue(NotificationViewCell.self, for: indexPath)
        
        guard let notification = fetchedResultsController?.object(at: indexPath) else {
            return cell
        }
        
        cell.notification = notification
        print(notification.date)
        print(Date())
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NotificationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = storyboard(.friendHistory)
            .instantiateViewController(ofType: FriendHistoryViewController.self)
        if let notification = fetchedResultsController?.object(at: indexPath) {
            updateNotificationRead(indexPath: indexPath)
            viewController.setDatabaseManager(databaseManager)
            viewController.friendID = notification.event?.friend?.objectID
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func tableView (_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let objectToDelete = fetchedResultsController?.object(at: indexPath) {
                databaseManager?.viewContext.delete(objectToDelete)
                do {
                    try databaseManager?.viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
                setEmptyView()
            }
        }
    }
}

// MARK: - DatabaseManagerClient

extension NotificationViewController: DatabaseManagerClient {
    func setDatabaseManager(_ manager: DatabaseManager) {
        databaseManager = manager
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension NotificationViewController: NSFetchedResultsControllerDelegate {
    // Implementation about Early crash
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}



