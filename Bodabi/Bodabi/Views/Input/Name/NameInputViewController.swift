//
//  NameInputViewController.swift
//  Bodabi
//
//  Created by Kim DongHwan on 26/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class NameInputViewController: UIViewController {
    
    @IBOutlet weak var guideLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    weak var delegate: HomeViewController?
    var entryRoute: EntryRoute!
    var newHolidayName: String? {
        didSet {
            setGuideLabel()
            setNextButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initGuideLabelText()
        initNavigationBar()
        initNextButton()
        initTapGesture()
    }
    
    private func initGuideLabelText() {
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addHolidayAtHome:
            guideLabel.text = "새로운 경조사의\n이름을 입력해주세요"
        case .addUpcomingEventAtHome,
             .addFriendAtHoliday:
            guideLabel.text = "친구의 이름이\n무엇인가요?"
        default:
            break
        }
    }
    
    private func initNavigationBar() {
        self.navigationController?.navigationBar.clear()
    }
    
    private func initNextButton() {
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addHolidayAtHome:
            nextButton.setTitle("완료", for: .normal)
        case .addUpcomingEventAtHome,
             .addFriendAtHoliday:
            nextButton.setTitle("다음", for: .normal)
        default:
            break
        }
        
        nextButton.isEnabled = false
        nextButton.backgroundColor = UIColor.offColor
    }
    
    private func setGuideLabel() {
        if newHolidayName == "" {
            initGuideLabelText()
        } else {
            guard let entryRoute = entryRoute else { return }
            
            switch entryRoute {
            case .addHolidayAtHome:
                let attributedString = NSMutableAttributedString()
                    .color(newHolidayName ?? "", fontSize: 25)
                    .bold("을(를)\n추가하시겠어요?", fontSize: 25)
                guideLabel.attributedText = attributedString
            case .addUpcomingEventAtHome,
                 .addFriendAtHoliday:
                let attributedString = NSMutableAttributedString()
                    .color(newHolidayName ?? "", fontSize: 25)
                    .bold("의\n이벤트인가요?", fontSize: 25)
                guideLabel.attributedText = attributedString
            default:
                break
            }
            
            
        }
    }
    
    private func setNextButton() {
        if newHolidayName == "" {
            initNextButton()
        } else {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.mainColor
        }
    }
    
    @IBAction func textFieldDidChanging(_ sender: UITextField) {
        newHolidayName = sender.text
    }
    
    @IBAction func touchUpNextButton(_ sender: UIButton) {
        delegate?.addedHoliday = newHolidayName
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissInputView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension NameInputViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newHolidayName = textField.text
        self.view.endEditing(true)
        return true
    }
}

extension NameInputViewController: UIGestureRecognizerDelegate {
    private func initTapGesture() {
        let viewTapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
        viewTapGesture.delegate = self
        self.view.addGestureRecognizer(viewTapGesture)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
