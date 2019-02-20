//
//  DateInputViewController.swift
//  Bodabi
//
//  Created by Kim DongHwan on 26/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class DateInputViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePickerTextField: UITextField!
    
    // MARK: - Property
    
    private let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.dateFormat = "MMMM dd, yyyy"
        formatter.locale = Locale.current
        return formatter
    }()
    private let pickerView: UIDatePicker = {
        let pickerView = UIDatePicker()
        pickerView.datePickerMode = .date
        pickerView.locale = Locale(identifier: "ko_KR")
        return pickerView
    }()
    private var keyboardDismissGesture: UITapGestureRecognizer?
    
    public var inputData: InputData?
    public var entryRoute: EntryRoute!
    private var databaseManager: DatabaseManager!
    private var date: Date? {
        didSet {
            setNextButton()
        }
    }
    
    struct Const {
        static let buttonAnimationScale: CGFloat = 1.35
        static let buttonAnimationDuration: TimeInterval = 0.12
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCalendar()
        initNavigationBar()
        initNextButton()
        initDatePickerTextField()
        initKeyboard()
    }
    
    // MARK: - Initialization
    
    private func initCalendar() {
        calendarView.delegate = self
        
        var calendarStyle: CalendarViewStyle = .init()
        
        calendarStyle.todayColor = .calendarTodayColor
        calendarStyle.dayColor = .black
        calendarStyle.weekColor = .calendarWeekColor
        calendarStyle.weekendColor = .calendarPointColor
        calendarStyle.eventColor = .mainColor
        calendarStyle.selectedColor = #colorLiteral(red: 0.8745098039, green: 0.9058823529, blue: 0.9764705882, alpha: 1)
        
        calendarView.style = calendarStyle
        calendarView.style.weekType = .korean // long short normal korean
        calendarView.style.firstWeekType = .sunday
    }
    
    private func initNavigationBar() {
        navigationController?.navigationBar.clear()
        
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_backButton"), style: .plain, target: self, action: #selector(popCurrentInputView(_:)))
        backButton.tintColor = UIColor.mainColor
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func initNextButton() {
        nextButton.setTitle("완료", for: .normal)
        nextButton.backgroundColor = UIColor.offColor
        nextButton.isEnabled = false
    }
    
    private func initDatePickerTextField() {
        let bar = UIToolbar()
        bar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self,
                                         action: #selector(touchUpPickerDoneButton))
        doneButton.tintColor = .mainColor
        let cancelButton = UIBarButtonItem(title: "취소", style: .done, target: self,
                                           action: #selector(tapBackground(_:)))
        cancelButton.tintColor = .mainColor
        let flextbleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: self, action: nil)
        bar.setItems([cancelButton, flextbleSpace, doneButton], animated: true)
        datePickerTextField.inputAccessoryView = bar
        datePickerTextField.inputView = pickerView
    }
    
    private func initKeyboard() {
        NotificationCenter.default
            .addObserver(self, selector: #selector(keyboardWillShow(_:)),
                         name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default
            .addObserver(self, selector: #selector(keyboardWillHide(_:)),
                         name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Setup
    
    private func setNextButton() {
        guard date != nil else {
            initNextButton()
            return
        }
        nextButton.backgroundColor = UIColor.mainColor
        nextButton.isEnabled = true
    }
    
    // MARK: - IBAction
    
    @IBAction func touchUpNextButton(_ sender: UIButton) {
        guard var inputData = inputData else { return }
        
        inputData.date = date
        InputManager.write(context: databaseManager.viewContext, entryRoute: entryRoute, data: inputData)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func touchUpMoveToDateButton(_ sender: UIButton) {
        sender.setScaleAnimation(scale: Const.buttonAnimationScale,
                                 duration: Const.buttonAnimationDuration)
        calendarView.movePage(addMonth: sender.tag)
    }
    
    @IBAction func dismissInputView(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Objc
    
    @objc func popCurrentInputView(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func touchUpPickerDoneButton() {
        calendarView.movePage(to: pickerView.date, shouldSelectedDay: true)
        view.endEditing(true)
    }
}

// MARK: - Keyboard will change

extension DateInputViewController {
    private func adjustKeyboardDismisTapGesture(isKeyboardVisible: Bool) {
        guard isKeyboardVisible else {
            guard let gesture = keyboardDismissGesture else { return }
            view.removeGestureRecognizer(gesture)
            keyboardDismissGesture = nil
            return
        }
        keyboardDismissGesture = UITapGestureRecognizer(target: self, action: #selector(tapBackground(_:)))
        guard let gesture = keyboardDismissGesture else { return }
        view.addGestureRecognizer(gesture)
    }
    
    @objc func tapBackground(_ sender: UITapGestureRecognizer?) {
        datePickerTextField.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(_ notification: Foundation.Notification) {
        adjustKeyboardDismisTapGesture(isKeyboardVisible: true)
    }
    
    @objc func keyboardWillHide(_ notification: Foundation.Notification) {
        adjustKeyboardDismisTapGesture(isKeyboardVisible: false)
    }
}

// MARK: - DatabaseManagerClient

extension DateInputViewController: DatabaseManagerClient {
    func setDatabaseManager(_ manager: DatabaseManager) {
        databaseManager = manager
    }
}

// MARK: - CalendarViewDelegate

extension DateInputViewController: CalendarViewDelegate {
    func calendar(_ calendar: CalendarView, didSelectedItem date: Date) {
        self.date = date
        dateLabel.text = date.toString(of: .year)
    }
    
    func calendar(_ calendar: CalendarView, currentVisibleItem date: Date) {
        self.date = nil
        dateLabel.text = date.toString(of: .noDay)
    }
}
