//
//  FriendsHeaderViewCell.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 27..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class FriendsHeaderViewCell: UITableViewCell {

    // MARK: - IBOutlet
    
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Property
    
    public var type: FriendsViewController.Section = .favoriteHeader {
        didSet {
            setUpUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Initialization
    
    private func setUpUI() {
        titleLabel.text = type.title
    }
}
