//
//  ItemCollectionViewFlowLayout.swift
//  Bodabi
//
//  Created by Kim DongHwan on 06/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class ItemCollectionViewFlowLayout : UICollectionViewFlowLayout {
    let cellSpacing: CGFloat = 8
    let lineSpacing: CGFloat = 8
    var location: Int = 0
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if let attributes = super.layoutAttributesForElements(in: rect) {
            for (index, attribute) in attributes.enumerated() {
                if index == 0 { continue }
                let prevLayoutAttributes = attributes[index - 1]
                let originX = prevLayoutAttributes.frame.maxX
                let originY = prevLayoutAttributes.frame.origin.y
                if originX + cellSpacing + attribute.frame.size.width <= collectionViewContentSize.width {
                    attribute.frame.origin.x = originX + cellSpacing
                    attribute.frame.origin.y = originY
                } else {
                    attribute.frame.origin.x = attributes[location].frame.origin.x
                    attribute.frame.origin.y = attributes[location].frame.origin.y + attributes[location].frame.size.height + lineSpacing
                    location = index
                }
            }
            
            location = 0
            return attributes
        }
        return nil
    }
}
