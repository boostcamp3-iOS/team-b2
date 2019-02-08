//
//  CollectionFetchedResultsDelegate.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 8..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CollectionFetchedResultsDelegate: NSObject, NSFetchedResultsControllerDelegate {
    
    private var collectionView: UICollectionView?
    private var blockOperation: BlockOperation = BlockOperation()
    
    init(_ collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
        
        switch type {
        case .insert:
            collectionView?.insertItems(at: [newIndexPath])
        case .delete:
            collectionView?.deleteItems(at: [indexPath])
        case .update:
            collectionView?.reloadItems(at: [indexPath])
        case .move:
            collectionView?.moveItem(at: indexPath, to: newIndexPath)
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperation = BlockOperation()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({ [weak self] in
            self?.blockOperation.start()
        }, completion: nil)
    }
}
