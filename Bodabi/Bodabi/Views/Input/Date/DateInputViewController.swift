//
//  DateInputViewController.swift
//  Bodabi
//
//  Created by Kim DongHwan on 26/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class DateInputViewController: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    
    let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.dateFormat = "MMMM dd, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    weak var delegate: HomeViewController?
    var entryRoute: EntryRoute!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDateLabel()
        initNavigationBar()
        initNextButton()
    }
    
    private func initDateLabel() {
        let date: Date = self.datePicker.date
        let dateString: String = self.dateFormatter.string(from: date)
        self.dateLabel.text = dateString
        
    }
    
    private func initNavigationBar() {
        self.navigationController?.navigationBar.clear()
        
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_backButton"), style: .plain, target: self, action: #selector(popCurrentInputView(_:)))
        
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    private func initNextButton() {
        nextButton.setTitle("완료", for: .normal)
        nextButton.backgroundColor = UIColor.offColor
        nextButton.isEnabled = false
    }
    
    private func setNextButton() {
        nextButton.backgroundColor = UIColor.mainColor
        nextButton.isEnabled = true
    }
    
    @IBAction func didDatePickerValueChaged(_ sender: UIDatePicker) {
        let holidayDate: Date = sender.date
        let dateString: String = self.dateFormatter.string(from: holidayDate)
        self.dateLabel.text = dateString
        
        setNextButton()
    }
    
    @IBAction func touchUpNextButton(_ sender: UIButton) {
        // 입력 받은 데이터 처리 이후 dismiss
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func popCurrentInputView(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dismissInputView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
