//
//  NotificationViewCell.swift
//  Bodabi
//
//  Created by jaehyeon lee on 27/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class NotificationViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var notificationDateLabel: UILabel!
    
    // MARK: - Property

    var notification: Notification? {
        didSet {
            guard let notification = notification else {
                iconImageView.image = UIImage()
                eventDateLabel.text = ""
                notificationLabel.text = ""
                notificationDateLabel.text = ""
                return
            }
            
            backgroundColor = notification.read ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0.9764705896, green: 0.9394879168, blue: 0.8803283655, alpha: 1)
            imageContainerView.makeRound(with: .heightRound)
            // TODO: - Image Setup for each holiday
            iconImageView.image = UIImage(named: "ic_fullStar")
            eventDateLabel.text = notification.date?.toString(of: .year)
            notificationLabel.text = notification.sentence
            notificationDateLabel.text = "1일 전"
        }
    }
    
    // MARK: - Life Cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.notification = nil
    }
}
