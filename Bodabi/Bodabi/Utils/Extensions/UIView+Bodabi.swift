//
//  UIView+Bodabi.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 25..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
extension UIView {
    public enum RoundType {
        case widthRound
        case heightRound
    }
    
    @IBInspectable
    public var cornerRadius: CGFloat {
        get{
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            guard let borderColor = layer.borderColor else { return nil }
            return UIColor(cgColor: borderColor)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @discardableResult
    public func makeRound(with type: RoundType) -> UIView {
        switch type {
        case .widthRound:
            layer.cornerRadius = self.bounds.size.width / 2
        case .heightRound:
            layer.cornerRadius = self.bounds.size.height / 2
        }
        return self
    }
}
