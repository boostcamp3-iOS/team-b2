//
//  FriendViewCell.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 27..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class FriendViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    
    struct Const {
        static let buttonAnimationScale: CGFloat = 1.18
        static let buttonAnimationDuration: TimeInterval = 0.18
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func touchUpFavoriteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.setScaleAnimation(scale: Const.buttonAnimationScale,
                                 duration: Const.buttonAnimationDuration)
    }
    
    public func configure(line hidden: Bool) {
        bottomView.isHidden = hidden
    }
}
