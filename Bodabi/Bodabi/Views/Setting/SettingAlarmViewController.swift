//
//  SettingAlarmViewController.swift
//  Bodabi
//
//  Created by jaehyeon lee on 16/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class SettingAlarmViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var defaultAlarmTime: UITextField!
    @IBOutlet weak var dafaultAlarmDday: UITextField!
    @IBOutlet weak var favoriteFirstAlarmDday: UITextField!
    @IBOutlet weak var favoriteSecondAlarmDday: UITextField!
    @IBOutlet weak var defaultAlarmTimeLabel: UILabel!
    @IBOutlet weak var defaultAlarmDdayLabel: UILabel!
    @IBOutlet weak var favoriteFirstAlarmDdayLabel: UILabel!
    @IBOutlet weak var favoriteSecondAlarmDdayLabel: UILabel!
    @IBOutlet weak var defaultAlarmTimeView: UIView!
    @IBOutlet weak var defaultAlarmDdayView: UIView!
    @IBOutlet weak var favoriteFirstAlarmDdayView: UIView!
    @IBOutlet weak var favoriteSecondAlarmDdayView: UIView!
    
    // MARK: - Property
    
    private let datePickerView = UIDatePicker()
    private let dayPickerView = UIPickerView()
    private let dDayData: [String: Int] = ["당일": 0, "하루 전": 1, "이틀 전": 2, "3일 전": 3, "5일 전": 5, "일주일 전": 7, "10일 전": 10, "2주 전": 14, "한 달 전": 30]
    private let dDayOptions: [String] = ["당일", "하루 전", "이틀 전", "3일 전", "5일 전", "일주일 전", "10일 전", "2주 전", "한 달 전"]
    private enum button: Int {
        case defaultTime = 1
        case defaultDday = 2
        case favoriteFirstDday = 3
        case favoriteSecondDday = 4
    }
    private var editingText: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initPickerView()
        initTapGesture()
        initLabel()
    }
    
    func initLabel() {
        let defaultDday = UserDefaults.standard.integer(forKey: "defaultAlarmDday")
        let favoriteFirstDday = UserDefaults.standard.integer(forKey: "favoriteFirstAlarmDday")
        let favoriteSecondDday = UserDefaults.standard.integer(forKey: "favoriteSecondAlarmDday")
        let defaultHour = UserDefaults.standard.integer(forKey: "defaultAlarmHour")
        let defaultMinutes = UserDefaults.standard.integer(forKey: "defaultAlarmMinutes")
    
        defaultAlarmTimeLabel.text = "\(defaultHour)시 \(defaultMinutes)분"
        defaultAlarmDdayLabel.text = dDayData.filter({$0.value ==  defaultDday}).keys.first ?? "하루 전"
        favoriteFirstAlarmDdayLabel.text = dDayData.filter({$0.value ==  favoriteFirstDday}).keys.first ?? "당일"
        favoriteSecondAlarmDdayLabel.text = dDayData.filter({$0.value ==  favoriteSecondDday}).keys.first ?? "일주일 전"
    }
    
    func initPickerView() {
        datePickerView.datePickerMode = .time
        dayPickerView.dataSource = self; dayPickerView.delegate = self
        defaultAlarmTime.inputView = datePickerView
        dafaultAlarmDday.inputView = dayPickerView
        favoriteFirstAlarmDday.inputView = dayPickerView
        favoriteSecondAlarmDday.inputView = dayPickerView
    }
    
    func initButtonColor() {
        defaultAlarmTimeView.backgroundColor = #colorLiteral(red: 0.9573978782, green: 0.9517062306, blue: 0.9617727399, alpha: 1)
        defaultAlarmDdayView.backgroundColor = #colorLiteral(red: 0.9573978782, green: 0.9517062306, blue: 0.9617727399, alpha: 1)
        favoriteFirstAlarmDdayView.backgroundColor = #colorLiteral(red: 0.9573978782, green: 0.9517062306, blue: 0.9617727399, alpha: 1)
        favoriteSecondAlarmDdayView.backgroundColor = #colorLiteral(red: 0.9573978782, green: 0.9517062306, blue: 0.9617727399, alpha: 1)
    }
    
    @IBAction func touchUpAlarmButton(_ sender: UIButton) {
        switch sender.tag {
        case button.defaultTime.rawValue:
            if !defaultAlarmTime.isFirstResponder {
                defaultAlarmTime.becomeFirstResponder()
                editingText = defaultAlarmTimeLabel
                initButtonColor()
                defaultAlarmTimeView.backgroundColor = #colorLiteral(red: 1, green: 0.9482591324, blue: 0.8059717466, alpha: 1)
            }
        case button.defaultDday.rawValue:
            if !dafaultAlarmDday.isFirstResponder {
                dafaultAlarmDday.becomeFirstResponder()
                editingText = defaultAlarmDdayLabel
                initButtonColor()
                defaultAlarmDdayView.backgroundColor = #colorLiteral(red: 1, green: 0.9482591324, blue: 0.8059717466, alpha: 1)
            }
        case button.favoriteFirstDday.rawValue:
            if !favoriteFirstAlarmDday.isFirstResponder {
                favoriteFirstAlarmDday.becomeFirstResponder()
                editingText = favoriteFirstAlarmDdayLabel
                initButtonColor()
                favoriteFirstAlarmDdayView.backgroundColor = #colorLiteral(red: 1, green: 0.9482591324, blue: 0.8059717466, alpha: 1)
            }
        case button.favoriteSecondDday.rawValue:
            if !favoriteSecondAlarmDday.isFirstResponder {
                favoriteSecondAlarmDday.becomeFirstResponder()
                editingText = favoriteSecondAlarmDdayLabel
                initButtonColor()
                favoriteSecondAlarmDdayView.backgroundColor = #colorLiteral(red: 1, green: 0.9482591324, blue: 0.8059717466, alpha: 1)
            }
        default: break
        }
    }
}



extension SettingAlarmViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dDayData.count
    }
}

extension SettingAlarmViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dDayOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        editingText?.text = dDayOptions[row]
        guard let editingType = editingText else { return }
        if let value = dDayData[editingType.text ?? ""] {
            switch editingType {
            case defaultAlarmDdayLabel:
                UserDefaults.standard.set(value, forKey: "defaultAlarmDday")
            case favoriteFirstAlarmDdayLabel:
                UserDefaults.standard.set(value, forKey: "favoriteFirstAlarmDday")
            case favoriteSecondAlarmDdayLabel:
                UserDefaults.standard.set(value, forKey: "favoriteSecondAlarmDday")
            default:
                break
            }
        }
    }
}
//
//class CursorlessTextField: UITextField {
//    override func caretRect(for position: UITextPosition) -> CGRect {
//        return CGRect.zero
//    }
//
//    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
//        return [UITextSelectionRect.init()]
//    }
//}

extension SettingAlarmViewController: UIGestureRecognizerDelegate {
    private func initTapGesture() {
        let viewTapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
        
        viewTapGesture.delegate = self
        scrollView.addGestureRecognizer(viewTapGesture)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        view.endEditing(true)
        return true
    }
}
