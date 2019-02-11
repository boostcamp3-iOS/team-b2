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
    
    // MARK: - Property
    
    private let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.dateFormat = "MMMM dd, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    public var inputData: InputData?
    public var entryRoute: EntryRoute!
    private var databaseManager: DatabaseManager!
    private var date: Date? {
        didSet {
            setNextButton()
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCalendar()
        initNavigationBar()
        initNextButton()
    }
    
    // MARK: - Initialization
    
    private func initCalendar() {
        calendarView.delegate = self
        
        var calendarStyle: CalendarViewStyle = .init()
        
        calendarStyle.todayColor = .calendarTodayColor
        calendarStyle.dayColor = .black
        calendarStyle.weekColor = .calendarWeekColor
        calendarStyle.weekendColor = .red
        calendarStyle.eventColor = .mainColor
        calendarStyle.selectedColor = .calendarSelectedColor
        
        calendarView.style = calendarStyle
        calendarView.style.weekType = .normal // long short normal
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
    
    @IBAction func dismissInputView(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Objc
    
    @objc func popCurrentInputView(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
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
