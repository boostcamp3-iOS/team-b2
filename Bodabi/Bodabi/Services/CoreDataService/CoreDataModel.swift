//
//  CoreDataModel.swift
//  Bodabi
//
//  Created by Kim DongHwan on 20/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation

enum Result<Value> {
    case success(Value)
    case failure(Error)
}
