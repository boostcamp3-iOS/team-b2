//
//  UIView+Shadow.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 14..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

extension UIView {
    func makeShadow(_ color: UIColor = UIColor.black,
                    opacity: Float = 1,
                    size offset: CGSize,
                    blur radius: CGFloat) {
        self.clipsToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
    }
}

