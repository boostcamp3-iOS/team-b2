//
//  UIStoryboard+Extensions.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 25..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    func instantiateViewController<T>(ofType type: T.Type) -> T where T: UIViewController {
        guard let viewController = instantiateViewController(withIdentifier: type.reuseIdentifier) as? T else {
            return T()
        }
        return viewController
    }
}
