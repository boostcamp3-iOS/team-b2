//
//  NSMutableAttributedString+Extension.swift
//  Bodabi
//
//  Created by Kim DongHwan on 27/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    func bold(_ text: String, fontSize: CGFloat) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: fontSize)]
        self.append(NSMutableAttributedString(string: text, attributes: attrs))
        return self
    }
    
    func normal(_ text: String, fontSize: CGFloat) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: fontSize)]
        self.append(NSMutableAttributedString(string: text, attributes: attrs))
        return self
    }
    
    func color(_ text: String, fontSize: CGFloat) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.calendarSelectedColor]
        self.append(NSMutableAttributedString(string: text, attributes: attrs))
        return self
    }
}
