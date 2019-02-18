//
//  HomeTitleViewCell.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 25..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class HomeTitleViewCell: UITableViewCell {
    
    // MARK: - IBOutlet

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addHolidayButton: UIButton!
    
    // MARK: - Property
    
    public var type: HomeViewController.Section = .holidaysHeader {
        didSet {
            initTitle(type)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Initialization
    
    private func initTitle(_ type: HomeViewController.Section) {
        titleLabel.text = type.title
    }
}
