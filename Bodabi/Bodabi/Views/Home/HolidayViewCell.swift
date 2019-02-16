//
//  HolidayViewCell.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 25..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class HolidayViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlet

    @IBOutlet weak var holidayImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - Property
    
    public var holiday: Holiday? {
        didSet {
            configure()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        holidayImageView.image = nil
    }
    
    // MARK: - Configure

    private func configure() {
        titleLabel.text = holiday?.title
        dateLabel.text = holiday?.date?.toString(of: .year)

        if let imageData = holiday?.image {
            holidayImageView.image = UIImage(data: imageData)
        }
    }
}
