//
//  TagHeaderViewCell.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 14..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class TagHeaderViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImage: UIView!
    
    public var tagType: TagType? {
        didSet {
            titleLabel.text = tagType?.title
            iconImage.backgroundColor = tagType?.color
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
