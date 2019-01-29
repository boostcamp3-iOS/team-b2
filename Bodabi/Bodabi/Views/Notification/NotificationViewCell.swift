//
//  NotificationViewCell.swift
//  Bodabi
//
//  Created by jaehyeon lee on 27/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class NotificationViewCell: UITableViewCell {
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var notificationDateLabel: UILabel!
    
    // MARK: - Properties

    var notification: Notification? {
        didSet {
            guard let notification = notification else {
                iconImageView.image = UIImage()
                eventDateLabel.text = ""
                notificationLabel.text = ""
                notificationDateLabel.text = ""
                return
            }
            
            imageContainerView.makeRound(with: .heightRound)
            // TODO: - Image Setup for each holiday
            iconImageView.image = UIImage(named: "ic_fullStar")
            eventDateLabel.text = notification.date.toString(of: .year)
            notificationLabel.text = notification.sentence
            notificationDateLabel.text = "1일 전"
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.notification = nil
    }
}
