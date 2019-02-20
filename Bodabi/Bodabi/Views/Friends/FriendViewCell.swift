//
//  FriendViewCell.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 27..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Contacts
import UIKit

class FriendViewCell: UITableViewCell {

    // MARK: - IBOutlet
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var selectedColorView: UIView!
    @IBOutlet weak var firstTagLabel: UILabel!
    @IBOutlet weak var secondTagLabel: UILabel!
    @IBOutlet weak var thirdTagLabel: UILabel!
    @IBOutlet weak var firstTagIcon: UIView!
    @IBOutlet weak var secondTagIcon: UIView!
    @IBOutlet weak var thirdTagIcon: UIView!
    
    // MARK: - Property
    
    public var friend: Friend? {
        didSet {
            favoriteButton.isHidden = false
            configure(name: friend?.name,
                      phoneNumber: friend?.phoneNumber,
                      favorite: friend?.favorite,
                      tags: friend?.tags)
        }
    }
    
    public var contact: CNContact? {
        didSet {
            guard let contact = contact else { return }
            favoriteButton.isHidden = true
            let phone = contact.phoneNumbers.first?.value
                .value(forKey: "digits") as? String
            configure(name: contact.familyName + contact.givenName,
                      phoneNumber: phone?.toPhoneFormat())
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        guard contact != nil else { return }
        selectedColorView.backgroundColor = selected ? #colorLiteral(red: 0.9764705896, green: 0.9394879168, blue: 0.8803283655, alpha: 1) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
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
    
    // MARK: - Method
    
    public func setLastLine(line hidden: Bool) {
        bottomView.isHidden = hidden
    }
    
    private func configure(name: String?, phoneNumber: String?,
                           favorite: Bool? = false, tags: [String]? = nil) {
        nameLabel.text = name
        phoneLabel.text = phoneNumber
        favoriteButton.isSelected = favorite ?? true
        guard let tags = tags else { return }
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
