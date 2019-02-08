//
//  TableFetchedResultsDelegate.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 8..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit
import CoreData

//class TableFetchedResultsDelegate: NSObject, NSFetchedResultsControllerDelegate {
//    private var tableView: UITableView?
//
//    init(_ tableView: UITableView) {
//        self.tableView = tableView
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
//
//        switch type {
//        case .insert:
//            tableView?.insertRows(at: [newIndexPath], with: .fade)
//        case .delete:
//            tableView?.deleteRows(at: [indexPath], with: .fade)
//        case .update:
//            tableView?.reloadRows(at: [indexPath], with: .fade)
//        case .move:
//            tableView?.moveRow(at: indexPath, to: newIndexPath)
//        }
//    }
//
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView?.beginUpdates()
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView?.endUpdates()
//    }
//}

protocol TableFetchedResultsDelegate: class {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
}

class TableFetchedResultsDataSource<FetchRequestResult: NSFetchRequestResult>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    let fetchedResultsController: NSFetchedResultsController<FetchRequestResult>
    weak var tableView: UITableView?
    weak var delegate: TableFetchedResultsDelegate?
    
    private var blockOperation = BlockOperation()

    init(fetchRequest: NSFetchRequest<FetchRequestResult>, context: NSManagedObjectContext, sectionNameKeyPath: String?) {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        super.init()
        fetchedResultsController.delegate = self
    }
    func performFetch() throws {
        try fetchedResultsController.performFetch()
    }
    func object(at indexPath: IndexPath) -> FetchRequestResult {
        return fetchedResultsController.object(at: indexPath)
    }
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections[section].numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let delegate = delegate {
            return delegate.tableView(tableView, cellForRowAt: indexPath)
        } else {
            return UITableViewCell()
        }
    }
    // MARK: - NSFetchedResultsControllerDelegate
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        let sectionIndexSet = IndexSet(integer: sectionIndex)
//        switch type {
//        case .insert:
//                tableView?.insertSections(sectionIndexSet,
//        case .delete:
//                tableView?.deleteSections(sectionIndexSet)
//        case .update:
//                tableView?.reloadSections(sectionIndexSet)
//        case .move:
//            assertionFailure()
//            break
//        }
//    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
        
        switch type {
        case .insert:
            tableView?.insertRows(at: [newIndexPath], with: .fade)
        case .delete:
            tableView?.deleteRows(at: [indexPath], with: .fade)
        case .update:
            tableView?.reloadRows(at: [indexPath], with: .fade)
        case .move:
            tableView?.moveRow(at: indexPath, to: newIndexPath)
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }
}
