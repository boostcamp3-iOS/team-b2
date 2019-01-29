//
//  HolidayViewCell.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 25..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class HolidayViewCell: UICollectionViewCell {

    @IBOutlet weak var holidayImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    public var holiday: Holiday? {
        didSet {
            configure()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func configure() {
        titleLabel.text = holiday?.title
        dateLabel.text = Date().toString(of: .year)
    }
}
