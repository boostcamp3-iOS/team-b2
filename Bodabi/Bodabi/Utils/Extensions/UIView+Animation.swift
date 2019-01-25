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
                           duration: TimeInterval) {
        let time = duration / 2
        
        UIView.animate(withDuration: time, animations: { [weak self] in
            self?.transform = CGAffineTransform(scaleX: scale, y: scale)
            }, completion:{ _ in
                UIView.animate(withDuration: time, animations: { [weak self] in
                    self?.transform = CGAffineTransform.identity
                })
        })
    }
}
