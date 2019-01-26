//
//  UIView+InitFromXib.swift
//  Bodabi
//
//  Created by Kim DongHwan on 26/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

extension UIView {
    static func instantiateFromXib(xibName: String) -> UIView? {
        return UINib(nibName: xibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? UIView
    }
}
