//
//  TagViewCell.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 13..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class TagViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    
    public var tagItem: Tag? {
        didSet {
            tagLabel.text = tagItem?.title
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectedView.backgroundColor = selected ? #colorLiteral(red: 0.9764705896, green: 0.9394879168, blue: 0.8803283655, alpha: 1) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }

}
