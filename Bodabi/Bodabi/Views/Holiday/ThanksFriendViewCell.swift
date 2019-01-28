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
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    
    struct Const {
        static let buttonAnimationScale: CGFloat = 1.3
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
