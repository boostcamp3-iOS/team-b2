//
//  UpcomingEventViewCell.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 25..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class UpcomingEventViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var holidayLabel: UILabel!
    @IBOutlet weak var lastHistoryLabel: UILabel!
    @IBOutlet weak var dDayLabel: UILabel!
    
    public var event: Event? {
        didSet {
            configure()
        }
    }
    
    struct Const {
        static let buttonAnimationScale: CGFloat = 1.35
        static let buttonAnimationDuration: TimeInterval = 0.12
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func touchUpAddFavoriteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.setScaleAnimation(scale: Const.buttonAnimationScale,
                                 duration: Const.buttonAnimationDuration)
    }
    
    private func configure() {
//        guard let event = event else { return }
//        let friend = Friend.dummies.filter { $0.id == event.friendId }.first
//        
//        nameLabel.text = friend?.name
//        holidayLabel.text = event.holiday
//        dDayLabel.text = "D-23"
//        
//        let friendHistories = History.dummies.filter { $0.friendId == (friend?.id ?? 0) }
//        guard let lastFriendHistory = friendHistories.last else { return }
//        lastHistoryLabel.text = String(format: "%@ %@",
//                                       lastFriendHistory.holiday,
//                                       lastFriendHistory.item)
    }
}
