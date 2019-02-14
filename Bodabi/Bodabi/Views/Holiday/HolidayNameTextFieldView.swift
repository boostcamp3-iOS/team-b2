//
//  HolidayNameTextFieldView.swift
//  Bodabi
//
//  Created by Kim DongHwan on 13/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

protocol HolidayNameTextFieldViewDelegate: class {
    func didTapDoneButton(_ textField: UITextField)
}

class HolidayNameTextFieldView: UIView {
    @IBOutlet weak var textField: UITextField!
    
    weak var delegate: HolidayNameTextFieldViewDelegate?
    
    @IBAction func touchUpDoneButton(_ sender: UITextField) {
        delegate?.didTapDoneButton(sender)
        print("did end editing")
    }
}
