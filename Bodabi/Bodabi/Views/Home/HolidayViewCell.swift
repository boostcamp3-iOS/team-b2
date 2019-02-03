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
    
//    public var holiday: Holiday? {
//        didSet {
//            configure()
//        }
//    }
   
    // FIXME: - Data dummy image
    let imageOfHoliday: [(holiday: String, image: UIImage)] = [
        (holiday: "생일", image: #imageLiteral(resourceName: "birthday")),
        (holiday: "출산", image: #imageLiteral(resourceName: "babyborn")),
        (holiday: "결혼", image: #imageLiteral(resourceName: "wedding")),
        (holiday: "장례", image: #imageLiteral(resourceName: "funeral"))
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func configure() {
//        titleLabel.text = holiday?.title
        dateLabel.text = Date().toString(of: .year)
        
//        imageOfHoliday.forEach {
//            if holiday?.title.contains($0.holiday) ?? true {
//                holidayImageView.image = $0.image
//                return
//            }
//        }
    }
}
