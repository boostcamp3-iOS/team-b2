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
    lazy var textField: UITextField! = {
        let textField = UITextField(frame: frame)
        textField.placeholder = "새로운 경조사 이름을 입력해주세요"
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.always
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField.addTarget(self, action: #selector(touchUpDoneButton(_:)), for: .touchUpInside)
        addSubview(textField)
        return textField
    }()
    
    weak var delegate: HolidayNameTextFieldViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func touchUpDoneButton(_ sender: UITextField) {
        print("touched")
    }
}
