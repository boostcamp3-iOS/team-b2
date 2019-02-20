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
    
    private var databaseManager: DatabaseManager!
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
    private var initialValues: [Int] = []
    
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
            defaultAlarmTimeLabel.text = "오전 " + "\(modifiedHour)시 \(defaultMinutes)분"
        } else {
            let modifiedHour: Int = defaultHour == 12 ? 24 : defaultHour
            defaultAlarmTimeLabel.text = "오후 " + "\(modifiedHour-12)시 \(defaultMinutes)분"
        }
        
        defaultAlarmDdayLabel.text = dDayData.filter({$0.value ==  defaultDday}).keys.first ?? "하루 전"
        favoriteFirstAlarmDdayLabel.text = dDayData.filter({$0.value ==  favoriteFirstDday}).keys.first ?? "당일"
        favoriteSecondAlarmDdayLabel.text = dDayData.filter({$0.value ==  favoriteSecondDday}).keys.first ?? "일주일 전"
    }
    
    private func initPickerView() {
        datePickerView.datePickerMode = .time
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        dayPickerView.dataSource = self; dayPickerView.delegate = self
        defaultAlarmTime.inputView = datePickerView
        dafaultAlarmDday.inputView = dayPickerView
        favoriteFirstAlarmDday.inputView = dayPickerView
        favoriteSecondAlarmDday.inputView = dayPickerView
    }
    
    private func initButtonColor() {
        defaultAlarmTimeView.backgroundColor = #colorLiteral(red: 0.9573978782, green: 0.9517062306, blue: 0.9617727399, alpha: 1)
        defaultAlarmDdayView.backgroundColor = #colorLiteral(red: 0.9573978782, green: 0.9517062306, blue: 0.9617727399, alpha: 1)
        favoriteFirstAlarmDdayView.backgroundColor = #colorLiteral(red: 0.9573978782, green: 0.9517062306, blue: 0.9617727399, alpha: 1)
        favoriteSecondAlarmDdayView.backgroundColor = #colorLiteral(red: 0.9573978782, green: 0.9517062306, blue: 0.9617727399, alpha: 1)
    }
    
    private func setTimeLabel() {
        guard let currentHour = Int(datePickerView.date.toString(of: .hour)) else { return }
        if currentHour < 12 {
            defaultAlarmTimeLabel.text = "오전 " + datePickerView.date.toString(of: .koreanTime)
        } else {
            defaultAlarmTimeLabel.text = "오후 " + datePickerView.date.toString(of: .koreanTime)
        }
    }
    
    func updateNotification() {
        var hasChanged: Bool = false
        
        let defaultDday = UserDefaults.standard.integer(forKey: DefaultsKey.defaultAlarmDday)
        let favoriteFirstDday = UserDefaults.standard.integer(forKey: DefaultsKey.favoriteFirstAlarmDday)
        let favoriteSecondDday = UserDefaults.standard.integer(forKey: DefaultsKey.favoriteSecondAlarmDday)
        let defaultHour = UserDefaults.standard.integer(forKey: DefaultsKey.defaultAlarmHour)
        let defaultMinutes = UserDefaults.standard.integer(forKey:  DefaultsKey.defaultAlarmMinutes)
        let currentValues: [Int] = [defaultHour, defaultMinutes, defaultDday, favoriteFirstDday, favoriteSecondDday]
        
        for (index, _) in currentValues.enumerated() {
            if currentValues[index] != initialValues[index] {
                hasChanged = true
            }
        }
        
        if hasChanged {
            NotificationSchedular.deleteAllNotification()
            let predicate: NSPredicate = NSPredicate(format: "isHandled = %@", NSNumber(value: false))
            databaseManager.batchDelete(typeString: "Notification", predicate: predicate) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            databaseManager.fetch(type: Event.self) { result, error in
                guard let result = result else { return }
                let events: [Event] = result
                for event in events {
                    var currentNotificaion: Notification?
                    guard let notificationDate = event.date?.addingTimeInterval(TimeInterval(exactly: -3600 * 24 * defaultDday + 3600 * defaultHour + 60 * defaultMinutes)!) else { return }
                    self.databaseManager.createNotification(event: event
                        , date: notificationDate, completion: { result, error in
                            currentNotificaion = result
                            if let notificationToSchedule = currentNotificaion {
                                NotificationSchedular.create(notification: notificationToSchedule, hour: defaultHour, minute: defaultMinutes)
                            }
                    })
                    
                    if event.favorite {
                        let favoriteDdays = [favoriteFirstDday, favoriteSecondDday]
                        for dDay in favoriteDdays {
                            var favoriteNotification: Notification?
                            guard let notificationDate = event.date?.addingTimeInterval(TimeInterval(exactly: -3600 * 24 * dDay + 3600 * defaultHour + 60 * defaultMinutes)!) else { return }
                            self.databaseManager.createNotification(event: event
                                , date: notificationDate, completion: { result, error in
                                    favoriteNotification = result
                                    if let notificationToSchedule = favoriteNotification {
                                        NotificationSchedular.create(notification: notificationToSchedule, hour: defaultHour, minute: defaultMinutes)
                                    }
                            })
                            
                        }
                    }
                }
            }
        }
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
                UserDefaults.standard.set(value, forKey: DefaultsKey.defaultAlarmDday)
            case favoriteFirstAlarmDdayLabel:
                UserDefaults.standard.set(value, forKey: DefaultsKey.favoriteFirstAlarmDday)
            case favoriteSecondAlarmDdayLabel:
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

extension SettingAlarmViewController: DatabaseManagerClient {
    func setDatabaseManager(_ manager: DatabaseManager) {
        databaseManager = manager
    }
}
