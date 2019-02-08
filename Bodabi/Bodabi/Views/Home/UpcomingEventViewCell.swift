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
        guard let event = event else { return }

        nameLabel.text = event.friend?.name
        holidayLabel.text = event.title
        dDayLabel.text = "D-\(event.dday)"
        
        let friendHistories = event.friend?.histories
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let histories = friendHistories?.sortedArray(using: [sortDescriptor])
        let lastHistory = histories?.first as? History
        guard let lastFriendHistory = lastHistory else { return }
        lastHistoryLabel.text = String(format: "%@ %@",
                                       lastFriendHistory.holiday ?? "",
                                       lastFriendHistory.item ?? "")
    }
}
