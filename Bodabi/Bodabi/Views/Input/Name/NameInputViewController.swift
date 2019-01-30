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
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var background: UIView!
    
    @IBOutlet weak var bottomConstriant: NSLayoutConstraint!
    @IBOutlet weak var heightConstriant: NSLayoutConstraint!

    private var originalBottomConstraint: CGFloat = 0.0
    private var originalHeightConstraint: CGFloat = 0.0
    
    weak var addHolidayDelegate: HolidayInputViewController?
    weak var addFriendDelegate: FriendsViewController?
    weak var homeDelegate: HolidayViewController?
    
    var entryRoute: EntryRoute!
    var friends: [Friend] = Friend.dummies
    var holidaies: [Holiday] = Holiday.dummies
    
    var newHolidayName: String? {
        didSet {
            setGuideLabel()
            setNextButton()
        }
    }
    
    var newFriendName: String? {
        didSet {
            setGuideLabel()
            setNextButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initKeyboard()
        initGuideLabelText()
        initNavigationBar()
        initTextField()
        initNextButton()
        initTapGesture()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    private func initKeyboard() {
        originalBottomConstraint = bottomConstriant.constant
        originalHeightConstraint = heightConstriant.constant
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChacnge(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChacnge(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChacnge(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    private func initGuideLabelText() {
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addHolidayAtHome:
            guideLabel.text = "새로운 경조사의\n이름을 입력해주세요"
        case .addUpcomingEventAtHome,
             .addFriendAtHoliday,
             .addFriendAtFriends:
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
        case .addHolidayAtHome,
             .addFriendAtFriends:
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
        if newHolidayName == "" || newFriendName == "" {
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
                    .color(newFriendName ?? "", fontSize: 25)
                    .bold("님의\n이벤트인가요?", fontSize: 25)
                guideLabel.attributedText = attributedString
            case .addFriendAtFriends:
                let attributedString = NSMutableAttributedString()
                    .color(newFriendName ?? "", fontSize: 25)
                    .bold("님을\n추가하시겠어요?", fontSize: 25)
                guideLabel.attributedText = attributedString
            default:
                break
            }
        }
    }
    
    private func setNextButton() {
        if newHolidayName == "" || newFriendName == "" {
            initNextButton()
        } else {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.mainColor
        }
    }
    
    @IBAction func textFieldDidChanging(_ sender: UITextField) {
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addFriendAtFriends,
             .addUpcomingEventAtHome:
            newFriendName = sender.text
        default:
            newHolidayName = sender.text
        }
    }
    
    @IBAction func touchUpNextButton(_ sender: UIButton) {
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addHolidayAtHome:
            guard let newHoliday = newHolidayName else { return }
            addHolidayDelegate?.myHolidaies.insert(newHoliday, at: 1)
            self.dismiss(animated: true, completion: nil)
        case .addUpcomingEventAtHome:
            let viewController = storyboard(.input)
                .instantiateViewController(ofType: HolidayInputViewController.self)
            
            viewController.entryRoute = entryRoute
            self.navigationController?.pushViewController(viewController, animated: true)
        case .addFriendAtHoliday:
            let viewController = storyboard(.input)
                .instantiateViewController(ofType: ItemInputViewController.self)
            
            viewController.entryRoute = entryRoute
            self.navigationController?.pushViewController(viewController, animated: true)
        case .addFriendAtFriends:
            guard let friendName = newFriendName else { return }
            addFriendDelegate?.friends.insert(Friend(id: 11, name: friendName, phoneNumber: "01012341234", tags: nil, favorite: false), at: 1)
            self.dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    
    @objc func keyboardWillChacnge(_ notification: Foundation.Notification) {
        if notification.name == UIWindow.keyboardWillChangeFrameNotification ||
            notification.name == UIWindow.keyboardWillShowNotification {
            let userInfo:NSDictionary = notification.userInfo! as NSDictionary
            let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            nextButton.titleEdgeInsets.top = 0
            bottomConstriant.constant = -keyboardHeight
            heightConstriant.constant = CGFloat(40)
            
            UIView.animate(withDuration: 1.0) {
                self.view.layoutIfNeeded()
            }
        } else {
            nextButton.titleEdgeInsets.top = -20
            
            bottomConstriant.constant = originalBottomConstraint
            heightConstriant.constant = originalHeightConstraint
            
            UIView.animate(withDuration: 1.0) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func popCurrentInputView(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dismissInputView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension NameInputViewController: UITextFieldDelegate {
    private func initTextField() {
        nameTextField.addBottomLine(height: 1.0, color: UIColor.lightGray)
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addHolidayAtHome:
            textField.placeholder = "졸업식"
        case .addUpcomingEventAtHome,
             .addFriendAtHoliday,
             .addFriendAtFriends:
            textField.placeholder = "김철수"
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let entryRoute = entryRoute else { return true }
        
        switch entryRoute {
        case .addFriendAtFriends,
             .addUpcomingEventAtHome:
            newFriendName = textField.text
        default:
            newHolidayName = textField.text
        }
        self.view.endEditing(true)
        return true
    }
}

extension NameInputViewController: UIGestureRecognizerDelegate {
    private func initTapGesture() {
        let viewTapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
        viewTapGesture.delegate = self
        self.background.addGestureRecognizer(viewTapGesture)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

extension NameInputViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addHolidayAtHome:
            let holiday = holidaies[indexPath.row]
            
            nameTextField.text = holiday.title
            newHolidayName = holiday.title
            
        case .addUpcomingEventAtHome,
             .addFriendAtHoliday,
             .addFriendAtFriends:
            let friend = friends[indexPath.row]
            
            nameTextField.text = friend.name
            newFriendName = friend.name
        default:
            break
        }
        
        self.view.endEditing(true)
    }
}

extension NameInputViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let entryRoute = entryRoute else { return 0 }
        
        switch entryRoute {
        case .addHolidayAtHome:
            return holidaies.count
        case .addUpcomingEventAtHome,
             .addFriendAtHoliday,
             .addFriendAtFriends:
            return friends.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
    
        guard let entryRoute = entryRoute else { return UITableViewCell() }
        
        switch entryRoute {
        case .addHolidayAtHome:
            let holiday = holidaies[indexPath.row]
            cell.textLabel?.text = holiday.title
            
        case .addUpcomingEventAtHome,
             .addFriendAtHoliday,
             .addFriendAtFriends:
            let friend = friends[indexPath.row]
            cell.textLabel?.text = friend.name
        default:
            break
        }
        
        return cell
    }
}
