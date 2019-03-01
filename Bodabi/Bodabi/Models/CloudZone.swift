//
//  CloudZone.swift
//  Bodabi
//
//  Created by jaehyeon lee on 25/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import CloudKit

struct CloudZone: RecordZone {
    let databaseType: DatabaseType
    init(databaseType: DatabaseType) {
        self.databaseType = databaseType
    }
}
