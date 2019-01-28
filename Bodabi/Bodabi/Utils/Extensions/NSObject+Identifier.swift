//
//  NSObject+Identifier.swift
//  Bodabi
//
//  Created by jaehyeon lee on 25/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation

extension NSObject {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
