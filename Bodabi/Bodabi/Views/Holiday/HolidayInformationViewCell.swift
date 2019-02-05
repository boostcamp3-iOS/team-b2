//
//  HolidayInformationView.swift
//  Bodabi
//
//  Created by Kim DongHwan on 05/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class HolidayInformationViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var incomeIcon: UIImageView!
    @IBOutlet weak var holidayImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension HolidayInformationViewCell: HolidayCellProtocol {
    func bind(item: HolidaySectionItem) {
        switch item {
        case let .information(income, image):
            incomeLabel.text = income
            guard let image = image else { return }
            holidayImageView.image = image
        default:
            return
        }
    }
}
