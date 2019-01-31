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
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - Property
    
    private let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.dateFormat = "MMMM dd, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    public weak var delegate: HomeViewController?
    public var entryRoute: EntryRoute!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initDateLabel()
        initNavigationBar()
        initNextButton()
    }
    
    // MARK: - Initialization
    
    private func initDateLabel() {
        let date: Date = self.datePicker.date
        let dateString: String = self.dateFormatter.string(from: date)
        dateLabel.text = dateString
        
    }
    
    private func initNavigationBar() {
        navigationController?.navigationBar.clear()
        
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_backButton"), style: .plain, target: self, action: #selector(popCurrentInputView(_:)))
        
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func initNextButton() {
        nextButton.setTitle("완료", for: .normal)
        nextButton.backgroundColor = UIColor.offColor
        nextButton.isEnabled = false
    }
    
    // MARK: - Setup
    
    private func setNextButton() {
        nextButton.backgroundColor = UIColor.mainColor
        nextButton.isEnabled = true
    }
    
    // MARK: - IBAction
    
    @IBAction func didDatePickerValueChaged(_ sender: UIDatePicker) {
        let holidayDate: Date = sender.date
        let dateString: String = self.dateFormatter.string(from: holidayDate)
        
        dateLabel.text = dateString

        setNextButton()
    }
    
    @IBAction func touchUpNextButton(_ sender: UIButton) {
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
