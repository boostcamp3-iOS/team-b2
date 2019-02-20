//
//  Error.swift
//  Bodabi
//
//  Created by Kim DongHwan on 20/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation

enum InputError: Error {
    case duplicateData
    
    var localizedDescription: String {
        switch self {
        case .duplicateData: return "Duplicate Data"
        }
    }
}

enum CoreDataError: Error {
    case fetchFailed
    case creationFailed
    case updateFailed
    case deletionFailed
    case batchUpdateFailed
    case batchDeletionFailed
    case loadFailed
    
    var localizedDescription: String {
        switch self {
        case .fetchFailed: return "Core data fetch failed"
        case .creationFailed: return "Core data creation failed"
        case .updateFailed: return "Core data update failed"
        case .deletionFailed: return "Core data deletion failed"
        case .batchUpdateFailed: return "Core data batch update failed"
        case .batchDeletionFailed: return "Core data batch deletion failed"
        case .loadFailed: return "Core data load failed"
        }
    }
}

enum CloudError: Error {
    
}

enum ContactError: Error {
    
}
