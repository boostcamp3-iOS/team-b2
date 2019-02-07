//
//  ThanksFriendCell.swift
//  Bodabi
//
//  Created by Kim DongHwan on 28/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class ThanksFriendViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var itemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension ThanksFriendViewCell: HolidayCellProtocol {
    func bind(friend: ThanksFriend) {
        nameLabel.text = friend.name
        itemLabel.text = friend.item
    }
}
