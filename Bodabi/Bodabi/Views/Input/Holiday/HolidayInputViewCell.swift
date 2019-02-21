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
    }
    
    private func initDeleteButton() {
        deleteButton.setImage(#imageLiteral(resourceName: "ic_delete"), for: .normal)
        deleteButton.isHidden = true
    }
    
    private func setDeleteButton() {
        deleteButton.isHidden = !isDeleting
    }
    
    @IBAction func touchUpHoildayButton(_ sender: UIButton) {
        sender.pulsate()
    }
}

extension HolidayInputViewCell: HolidayInputViewCellProtocol {
    func bind(_ data: String) {
        if data == "+" {
            holidaybutton.backgroundColor = .offColor
        } else {
            holidaybutton.backgroundColor = .starColor
        }
        
        holidaybutton.setTitle(data, for: .normal)
    }
}
