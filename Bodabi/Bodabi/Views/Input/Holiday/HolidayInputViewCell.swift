//
//  File.swift
//  Bodabi
//
//  Created by Kim DongHwan on 26/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class HolidayInputViewCell: UITableViewCell {

    @IBOutlet weak var holidaybutton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    public var isDeleting: Bool = false {
        didSet {
            setDeleteButton()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initHolidayButton()
        initDeleteButton()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isDeleting = false
    }
    
    private func initHolidayButton() {
        holidaybutton.layer.cornerRadius = 10
        holidaybutton.backgroundColor = UIColor.starColor
    }
    
    private func initDeleteButton() {
        deleteButton.setImage(#imageLiteral(resourceName: "ic_delete"), for: .normal)
        deleteButton.isHidden = true
    }
    
    private func setDeleteButton() {
        if isDeleting {
            deleteButton.isHidden = false
        } else {
            deleteButton.isHidden = true
        }
    }
    
    @IBAction func touchUpHoildayButton(_ sender: UIButton) {
        sender.pulsate()
    }
}
