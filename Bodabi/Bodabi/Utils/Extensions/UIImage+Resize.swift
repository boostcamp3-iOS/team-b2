//
//  UIImage+Resize.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 16..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

extension UIImage {
    func resize(scale: CGFloat) -> Data? {
        let newSize = CGSize(width: size.width * scale,
                             height: size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage?.jpegData(compressionQuality: 1.0)
    }
    
    func jpeg(_ jpegQuality: CGFloat) -> Data? {
        return jpegData(compressionQuality: jpegQuality)
    }
}
