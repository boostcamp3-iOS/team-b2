//
//  UIButton+Animation.swift
//  Bodabi
//
//  Created by Kim DongHwan on 27/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

extension UIButton {
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.1
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.damping = 1.0
        
        self.layer.add(pulse, forKey: nil)
    }
}
