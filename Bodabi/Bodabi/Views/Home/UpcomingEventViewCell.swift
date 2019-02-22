//
//  UpcomingEventViewCell.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 25..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class UpcomingEventViewCell: UITableViewCell {
    
    // MARK: - IBOutlet

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var holidayLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var lastHistoryView: UIView!
    @IBOutlet weak var lastHistoryLabel: UILabel!
    @IBOutlet weak var lastHistoryImageView: UIImageView!
    @IBOutlet weak var dDayLabel: UILabel!
    @IBOutlet weak var leftColorView: UIView!
    @IBOutlet weak var rightColorView: UIImageView!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet var deleteActionConstraint: NSLayoutConstraint!
    
   
    // MARK: - Property
    
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
        
        initLastHistory()
        initDeleteButton()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // MARK: - Initialization
    
    private func initLastHistory() {
        lastHistoryView.isHidden = true
    }
    
    private func initDeleteButton() {
        deleteButton.isHidden = true
    }
    
    // MARK: - Configure
    
    private func configure() {
        guard let event = event, let title = event.title else { return }

        nameLabel.text = event.friend?.name
        holidayLabel.text = event.title
        dDayLabel.text = event.dday == 0 ? "Today" : "D-\(event.dday)"
        favoriteButton.isSelected = event.favorite
        leftColorView.backgroundColor = DefaultHolidayType.parse(with: title)?.color ?? #colorLiteral(red: 0.961987555, green: 0.7720394135, blue: 0.4948675036, alpha: 1)
        rightColorView.tintColor = event.dday == 0 ? #colorLiteral(red: 0.5507660194, green: 0.5332616567, blue: 0.5859107449, alpha: 1) : #colorLiteral(red: 0.6840819716, green: 0.6623405814, blue: 0.7277336717, alpha: 1)
        
        let friendHistories = event.friend?.histories
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let histories = friendHistories?.sortedArray(using: [sortDescriptor])
        guard let lastHistory = histories?.first as? History else {
            initLastHistory()
            return
        }
        lastHistoryView.isHidden = false
        lastHistoryImageView.image = lastHistory.isTaken ? #imageLiteral(resourceName: "ic_boxIn") : #imageLiteral(resourceName: "ic_boxOut")
        lastHistoryLabel.text = String(format: "%@ %@",
                                       lastHistory.holiday ?? "",
                                       lastHistory.item?.insertComma() ?? "")
    }
    
    // MARK: - Method
    
    public func showDeleteButton() {
        deleteButton.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.deleteActionConstraint.isActive = false
            self.layoutIfNeeded()
        }) { (_) in
            self.deleteButton.setScaleAnimation(scale: 1.12, duration: 0.12)
        }
    }
    
    public func hideDeleteButton() {
        UIView.animate(withDuration: 0.3, animations: {
            self.deleteActionConstraint.isActive = true
            self.layoutIfNeeded()
        }) { (_) in
            self.deleteButton.isHidden = true
        }
    }
}
