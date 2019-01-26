//
//  HomeTitleViewCell.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 25..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class HomeTitleViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sortingButton: UIButton!
    @IBOutlet weak var addHolidayButton: UIButton!
    
    public var type: HomeViewController.Section = .myHoliday {
        didSet {
            setUpUI(type)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setUpUI(_ type: HomeViewController.Section) {
        titleLabel.text = type.title
        
        switch type {
        case .myHoliday:
            sortingButton.isHidden = true
        case .upcomingEvent:
            sortingButton.isHidden = false
        default:
            break
        }
    }
}
