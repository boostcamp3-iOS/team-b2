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
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var firstTagLabel: UILabel!
    @IBOutlet weak var secondTagLabel: UILabel!
    @IBOutlet weak var thirdTagLabel: UILabel!
    @IBOutlet weak var firstTagIcon: UIView!
    @IBOutlet weak var secondTagIcon: UIView!
    @IBOutlet weak var thirdTagIcon: UIView!
    
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
        
        clear()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        clear()
    }
    
    // MARK: - Method
    
    private func clear() {
        firstTagIcon.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        secondTagIcon.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        thirdTagIcon.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        firstTagLabel.text = ""
        secondTagLabel.text = ""
        thirdTagLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Method
    
    public func setLastLine(line hidden: Bool) {
        bottomView.isHidden = hidden
    }
    
    private func configure() {
        nameLabel.text = friend?.name
        phoneLabel.text = friend?.phoneNumber
        favoriteButton.isSelected = friend?.favorite ?? true
        guard let tags = friend?.tags else { return }
        if tags.count >= 1 {
            firstTagLabel.text = tags[0]
            firstTagIcon.backgroundColor = Tag.type(of: tags[0])?.color
        }
        if tags.count >= 2 {
            secondTagLabel.text = tags[1]
            secondTagIcon.backgroundColor = Tag.type(of: tags[1])?.color
        }
        if tags.count == 3 {
            thirdTagLabel.text = tags[2]
            thirdTagIcon.backgroundColor = Tag.type(of: tags[2])?.color
        }
    }
}
