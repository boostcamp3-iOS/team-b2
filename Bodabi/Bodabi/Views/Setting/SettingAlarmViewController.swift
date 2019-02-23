//
//  SettingAlarmViewController.swift
//  Bodabi
//
//  Created by jaehyeon lee on 16/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit
import CoreData

class SettingAlarmViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var fields: [UITextField]!
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var views: [UIView]!
    
    // MARK: - Property
    
    private var databaseManager: CoreDataManager!
    private let datePickerView = UIDatePicker()
    private let dayPickerView = UIPickerView()
    private let dDayData: [String: Int] = ["당일": 0, "하루 전": 1, "이틀 전": 2, "3일 전": 3, "5일 전": 5, "일주일 전": 7, "10일 전": 10, "2주 전": 14, "한 달 전": 30]
    private let dDayOptions: [String] = ["당일", "하루 전", "이틀 전", "3일 전", "5일 전", "일주일 전", "10일 전", "2주 전", "한 달 전"]
    private enum Button: Int {
        case defaultTime = 0
        case defaultDday = 1
        case favoriteFirstDday = 2
        case favoriteSecondDday = 3
    }
    private var editingText: UILabel?
    private var initialValues: [Int] = []
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initPickerView()
        initTapGesture()
        initLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        updateNotification()
        navigationController?.popToRootViewController(animated: false)
    }
    
    private func initLabel() {
        let defaultDday = UserDefaults.standard.integer(forKey: DefaultsKey.defaultAlarmDday)
        let favoriteFirstDday = UserDefaults.standard.integer(forKey: DefaultsKey.favoriteFirstAlarmDday)
        let favoriteSecondDday = UserDefaults.standard.integer(forKey: DefaultsKey.favoriteSecondAlarmDday)
        let defaultHour = UserDefaults.standard.integer(forKey: DefaultsKey.defaultAlarmHour)
        let defaultMinutes = UserDefaults.standard.integer(forKey:  DefaultsKey.defaultAlarmMinutes)
        initialValues.append(contentsOf: [defaultHour, defaultMinutes, defaultDday, favoriteFirstDday, favoriteSecondDday])
        
        if defaultHour < 12 {
            let modifiedHour: Int = defaultHour == 0 ? 12 : defaultHour
            labels[Button.defaultTime.rawValue].text = "오전 " + "\(modifiedHour)시 \(defaultMinutes)분"
        } else {
            let modifiedHour: Int = defaultHour == 12 ? 24 : defaultHour
            labels[Button.defaultTime.rawValue].text = "오후 " + "\(modifiedHour-12)시 \(defaultMinutes)분"
        }
        
        labels[Button.defaultDday.rawValue].text = dDayData.filter({$0.value ==  defaultDday}).keys.first ?? "하루 전"
        labels[Button.favoriteFirstDday.rawValue].text = dDayData.filter({$0.value ==  favoriteFirstDday}).keys.first ?? "당일"
        labels[Button.favoriteSecondDday.rawValue].text = dDayData.filter({$0.value ==  favoriteSecondDday}).keys.first ?? "일주일 전"
    }
    
    private func initPickerView() {
        datePickerView.datePickerMode = .time
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        dayPickerView.dataSource = self; dayPickerView.delegate = self
        fields[Button.defaultTime.rawValue].inputView = datePickerView
        fields[Button.defaultDday.rawValue].inputView = dayPickerView
        fields[Button.favoriteFirstDday.rawValue].inputView = dayPickerView
        fields[Button.favoriteSecondDday.rawValue].inputView = dayPickerView
        
        let bar = UIToolbar()
        bar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(touchUpPickerDoneButton))
        doneButton.tintColor = .mainColor
        let cancelButton = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(gestureRecognizer(_: shouldReceive:)))
        cancelButton.tintColor = .mainColor
        let flextbleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        bar.setItems([cancelButton, flextbleSpace, doneButton], animated: true)
        fields.forEach({ $0.inputAccessoryView = bar })
    }
    
    private func initButtonColor() {
        views[Button.defaultTime.rawValue].backgroundColor = #colorLiteral(red: 0.9573978782, green: 0.9517062306, blue: 0.9617727399, alpha: 1)
        views[Button.defaultDday.rawValue].backgroundColor = #colorLiteral(red: 0.9573978782, green: 0.9517062306, blue: 0.9617727399, alpha: 1)
        views[Button.favoriteFirstDday.rawValue].backgroundColor = #colorLiteral(red: 0.9573978782, green: 0.9517062306, blue: 0.9617727399, alpha: 1)
        views[Button.favoriteSecondDday.rawValue].backgroundColor = #colorLiteral(red: 0.9573978782, green: 0.9517062306, blue: 0.9617727399, alpha: 1)
    }
    
    private func setTimeLabel() {
        guard let currentHour = Int(datePickerView.date.toString(of: .hour)) else { return }
        if currentHour < 12 {
            labels[Button.defaultTime.rawValue].text = "오전 " + datePickerView.date.toString(of: .koreanTime)
        } else {
            labels[Button.defaultTime.rawValue].text = "오후 " + datePickerView.date.toString(of: .koreanTime)
        }
    }
    
    func checkValueChanged(_ currentHour: Int,_ currentMinutes: Int, _ currentDday: Int,_ currentFirstDday: Int,_ currentSecondDday: Int) -> Bool {
        let currentValues = [currentHour, currentMinutes, currentDday, currentFirstDday, currentSecondDday]
        for (index, _) in currentValues.enumerated() {
            if currentValues[index] != initialValues[index] {
                return true
            }
        }
        return false
    }
    
    func updateNotification() {
        let defaultDday = UserDefaults.standard.integer(forKey: DefaultsKey.defaultAlarmDday)
        let favoriteFirstDday = UserDefaults.standard.integer(forKey: DefaultsKey.favoriteFirstAlarmDday)
        let favoriteSecondDday = UserDefaults.standard.integer(forKey: DefaultsKey.favoriteSecondAlarmDday)
        let defaultHour = UserDefaults.standard.integer(forKey: DefaultsKey.defaultAlarmHour)
        let defaultMinutes = UserDefaults.standard.integer(forKey:  DefaultsKey.defaultAlarmMinutes)
        
        if !checkValueChanged(defaultHour, defaultMinutes, defaultDday, favoriteFirstDday, favoriteSecondDday) { return }
        
        databaseManager.fetch(type: Event.self) { result in
            switch result {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(events):
                for event in events {
                    guard let notifications = event.notifications?.allObjects as? [Notification] else { return }
                    guard let defaultNotificationDate = event.date?.addingTimeInterval(TimeInterval(exactly: -1 * Int.day * (defaultDday + 1) + Int.hour * defaultHour + Int.minute * defaultMinutes)!) else { return }
                        NotificationSchedular.deleteAllNotification()
                        notifications.forEach { notification in
                        if !notification.isHandled {
                            self.databaseManager.updateNotification(object: notification, date: defaultNotificationDate)  {
                                switch $0 {
                                case let .failure(error):
                                    print(error.localizedDescription)
                                case let .success(updatedNotification):
                                    NotificationSchedular.create(notification: updatedNotification,
                                                                 hour: defaultHour,
                                                                 minute: defaultMinutes)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc private func touchUpPickerDoneButton() {
        switch editingText {
        case labels[Button.defaultTime.rawValue]:
            datePickerValueChanged()
        case labels[Button.defaultDday.rawValue],
             labels[Button.favoriteFirstDday.rawValue],
             labels[Button.favoriteSecondDday.rawValue]:
            self.pickerView(dayPickerView, didSelectRow: dayPickerView.selectedRow(inComponent: 0), inComponent: 0)
        default:
            break
        }
        view.endEditing(true)
        initButtonColor()
    }
    
    @objc private func datePickerValueChanged() {
        let hour = datePickerView.date.toString(of: .hour)
        let minutes = datePickerView.date.toString(of: .minutes)
        
        setTimeLabel()
        UserDefaults.standard.set(Int(hour), forKey: DefaultsKey.defaultAlarmHour)
        UserDefaults.standard.set(Int(minutes), forKey: DefaultsKey.defaultAlarmMinutes)
    }
    
    @IBAction func touchUpAlarmButton(_ sender: UIButton) {
        switch sender.tag {
        case Button.defaultTime.rawValue + 1:
            if !fields[Button.defaultTime.rawValue].isFirstResponder {
                fields[Button.defaultTime.rawValue].becomeFirstResponder()
                editingText = labels[Button.defaultTime.rawValue]
                initButtonColor()
                views[Button.defaultTime.rawValue].backgroundColor = #colorLiteral(red: 1, green: 0.9482591324, blue: 0.8059717466, alpha: 1)
            }
        case Button.defaultDday.rawValue + 1:
            if !fields[Button.defaultDday.rawValue].isFirstResponder {
                fields[Button.defaultDday.rawValue].becomeFirstResponder()
                editingText = labels[Button.defaultDday.rawValue]
                initButtonColor()
                views[Button.defaultDday.rawValue].backgroundColor = #colorLiteral(red: 1, green: 0.9482591324, blue: 0.8059717466, alpha: 1)
            }
        case Button.favoriteFirstDday.rawValue + 1:
            if !fields[Button.favoriteFirstDday.rawValue].isFirstResponder {
                fields[Button.favoriteFirstDday.rawValue].becomeFirstResponder()
                editingText = labels[Button.favoriteFirstDday.rawValue]
                initButtonColor()
                views[Button.favoriteFirstDday.rawValue].backgroundColor = #colorLiteral(red: 1, green: 0.9482591324, blue: 0.8059717466, alpha: 1)
            }
        case Button.favoriteSecondDday.rawValue + 1:
            if !fields[Button.favoriteSecondDday.rawValue].isFirstResponder {
                fields[Button.favoriteSecondDday.rawValue].becomeFirstResponder()
                editingText = labels[Button.favoriteSecondDday.rawValue]
                initButtonColor()
                views[Button.favoriteSecondDday.rawValue].backgroundColor = #colorLiteral(red: 1, green: 0.9482591324, blue: 0.8059717466, alpha: 1)
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
            case labels[Button.defaultDday.rawValue]:
                UserDefaults.standard.set(value, forKey: DefaultsKey.defaultAlarmDday)
            case labels[Button.favoriteFirstDday.rawValue]:
                UserDefaults.standard.set(value, forKey: DefaultsKey.favoriteFirstAlarmDday)
            case labels[Button.favoriteSecondDday.rawValue]:
                UserDefaults.standard.set(value, forKey: DefaultsKey.favoriteSecondAlarmDday)
            default:
                break
            }
        }
    }
}

extension SettingAlarmViewController: UIGestureRecognizerDelegate {
    private func initTapGesture() {
        let viewTapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
        
        viewTapGesture.delegate = self
        scrollView.addGestureRecognizer(viewTapGesture)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        view.endEditing(true)
        initButtonColor()
        return true
    }
}

extension SettingAlarmViewController: CoreDataManagerClient {
    func setDatabaseManager(_ manager: CoreDataManager) {
        databaseManager = manager
    }
}
