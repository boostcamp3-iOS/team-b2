//
//  UINavigationController+Extensions.swift
//  Bodabi
//
//  Created by jaehyeon lee on 20/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .lightContent
    }
}
