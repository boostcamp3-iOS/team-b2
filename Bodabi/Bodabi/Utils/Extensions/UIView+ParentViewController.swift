//
//  UIView+ParentViewController.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 31..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func findParentViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findParentViewController()
        } else {
            return nil
        }
    }
}

