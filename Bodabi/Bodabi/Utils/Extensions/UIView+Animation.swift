//
//  UIView+Animation.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 25..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func setScaleAnimation(scale: CGFloat,
                           duration: TimeInterval,
                           repeat: Float = 1.0) {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = duration
        pulse.fromValue = 1.0
        pulse.toValue = scale
        pulse.autoreverses = true
        pulse.repeatCount = 1

        layer.add(pulse, forKey: nil)
    }
}
