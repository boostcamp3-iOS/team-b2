//
//  FriendsIndexViewCell.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 12..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class FriendsIndexViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlet

    @IBOutlet weak var indexLabel: UILabel!
    
    // MARK: - Property
    
    public var indexTitle: Character? {
        didSet {
            guard let title = indexTitle else { return }
            indexLabel.text = String(title)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
