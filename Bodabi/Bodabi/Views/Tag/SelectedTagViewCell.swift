//
//  SelectedTagViewCell.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 13..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class SelectedTagViewCell: UICollectionViewCell {
    
    @IBOutlet weak var selectedTagLabel: UILabel!
    
    public var tagItem: Tag? {
        didSet {
            backgroundColor = tagItem?.type.color
            selectedTagLabel.text = tagItem?.title
        }
    }
}
