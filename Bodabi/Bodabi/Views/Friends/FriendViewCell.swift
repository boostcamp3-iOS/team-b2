//
//  FriendViewCell.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 27..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class FriendViewCell: UITableViewCell {

    // MARK: - IBOutlet
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    
    // MARK: - Property
    
    public var friend: Friend? {
        didSet {
            configure()
        }
    }
    
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
    
    // MARK: - Method
    
    public func setLastLine(line hidden: Bool) {
        bottomView.isHidden = hidden
    }
    
    // MARK: - Configure
    
    private func configure() {
        nameLabel.text = friend?.name
        favoriteButton.isSelected = friend?.favorite ?? true
    }
}
