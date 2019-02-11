//
//  NameInputViewController.swift
//  Bodabi
//
//  Created by Kim DongHwan on 26/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit
import CoreData

class NameInputViewController: UIViewController {
    
    // MARK: - @IBOutlets
    
    @IBOutlet weak var guideLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var bottomConstriant: NSLayoutConstraint!
    @IBOutlet weak var heightConstriant: NSLayoutConstraint!

    // MARK: - Properties
    
    public weak var delegate: HolidayInputViewController?
    public var entryRoute: EntryRoute!
    public var inputData: InputData?
    
    private var databaseManager: DatabaseManager!
    private var friends: [Friend]?
    private var searchedFriends: [Friend]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var originalBottomConstraint: CGFloat = 0.0
    private var originalHeightConstraint: CGFloat = 0.0
    
    private var newHolidayName: String? {
        didSet {
            setGuideLabel()
            setNextButton()
        }
    }
    private var newFriendName: String? {
        didSet {
            setGuideLabel()
            setNextButton()
            setTableView()
        }
    }
    
    // MARK: - Lifecycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        initKeyboard()
        initGuideLabelText()
        initNavigationBar()
        initTextField()
        initNextButton()
        initTapGesture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    // MARK: - Initialization Methods
    
    private func initData() {
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addHolidayAtHome:
            print("addFriendAtHoliday")
        case .addUpcomingEventAtHome,
             .addHistoryAtHoliday,
             .addFriendAtFriends:
            fetchFriend()
        default:
            break
        }
    }
    
    private func fetchFriend() {
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            if let result: [Friend] = try databaseManager?.viewContext.fetch(request) {
                friends = result
            }
        } catch {
            print(error.localizedDescription)
        }
        
        tableView.reloadData()
    }
    
    private func initTableView() {
        tableView.delegate = self; tableView.dataSource = self
    }
    
    private func initKeyboard() {
        originalBottomConstraint = bottomConstriant.constant
        originalHeightConstraint = heightConstriant.constant
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    private func initGuideLabelText() {
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addHolidayAtHome:
            guideLabel.text = "새로운 경조사의\n이름을 입력해주세요"
        case .addUpcomingEventAtHome,
             .addHistoryAtHoliday,
             .addFriendAtFriends:
            guideLabel.text = "친구의 이름이\n무엇인가요?"
        default:
            break
        }
    }
    
    private func initNavigationBar() {
        navigationController?.navigationBar.clear()
    }
    
    private func initNextButton() {
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addHolidayAtHome,
             .addFriendAtFriends:
            nextButton.setTitle("완료", for: .normal)
        case .addUpcomingEventAtHome,
             .addHistoryAtHoliday:
            nextButton.setTitle("다음", for: .normal)
        default:
            break
        }
        
        nextButton.isEnabled = false
        nextButton.backgroundColor = UIColor.offColor
    }
    
    // MARK: - Setup Method
    
    private func setTableView() {
        let searchedFriends = friends?.filter { friend in
            friend.name?.hasPrefix(newFriendName ?? "") ?? false
        }
        
        self.searchedFriends = searchedFriends
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
            case .addUpcomingEventAtHome:
                let attributedString = NSMutableAttributedString()
                    .color(newFriendName ?? "", fontSize: 25)
                    .bold("님의\n이벤트인가요?", fontSize: 25)
                guideLabel.attributedText = attributedString
            case .addFriendAtFriends:
                let attributedString = NSMutableAttributedString()
                    .color(newFriendName ?? "", fontSize: 25)
                    .bold("님을\n추가하시겠어요?", fontSize: 25)
                guideLabel.attributedText = attributedString
            case .addHistoryAtHoliday:
                let attributedString = NSMutableAttributedString()
                    .color(newFriendName ?? "", fontSize: 25)
                    .bold("님이\n축하해주셨나요?", fontSize: 25)
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
    
    private func moveToNextInputView() {
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addHolidayAtHome:
            guard let newHolidayName = newHolidayName else { return }
            delegate?.myHolidaies?.insert(newHolidayName, at: 1)
            dismiss(animated: true, completion: nil)
        case .addUpcomingEventAtHome:
            let viewController = storyboard(.input)
                .instantiateViewController(ofType: HolidayInputViewController.self)
            
            viewController.entryRoute = entryRoute
            inputData?.name = newFriendName
            viewController.inputData = inputData
            viewController.setDatabaseManager(databaseManager)
            navigationController?.pushViewController(viewController, animated: true)
        case .addHistoryAtHoliday:
            let viewController = storyboard(.input)
                .instantiateViewController(ofType: ItemInputViewController.self)
            
            viewController.setDatabaseManager(databaseManager)
            viewController.entryRoute = entryRoute

            inputData?.name = newFriendName
            viewController.inputData = inputData
            navigationController?.pushViewController(viewController, animated: true)
        case .addFriendAtFriends:
            inputData?.name = newFriendName
            
            guard let inputData = inputData else { return }
            InputManager.write(context: databaseManager.viewContext, entryRoute: entryRoute, data: inputData)
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    
    // MARK: - @IBActions
    
    @IBAction func textFieldDidChanging(_ sender: UITextField) {
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addFriendAtFriends,
             .addUpcomingEventAtHome,
             .addHistoryAtHoliday:
            newFriendName = sender.text
        default:
            newHolidayName = sender.text
        }
    }
    
    @IBAction func touchUpNextButton(_ sender: UIButton) {
        moveToNextInputView()
    }
    
    @IBAction func dismissInputView(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - @objcs
    
    @objc func keyboardWillChange(_ notification: Foundation.Notification) {
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
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension NameInputViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let entryRoute = entryRoute else { return 0 }
        
        switch entryRoute {
        case .addHolidayAtHome:
            return 0
        case .addUpcomingEventAtHome,
             .addHistoryAtHoliday,
             .addFriendAtFriends:
            if newFriendName == nil || newFriendName == "" {
                return friends?.count ?? 0
            } else {
                return searchedFriends?.count ?? 0
            }
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        
        guard let entryRoute = entryRoute else { return UITableViewCell() }
        
        switch entryRoute {
        case .addUpcomingEventAtHome,
             .addHistoryAtHoliday,
             .addFriendAtFriends:
            if newFriendName == nil || newFriendName == "" {
                let friend = friends?[indexPath.row]
                
                cell.textLabel?.text = friend?.name
            } else {
                let friend = searchedFriends?[indexPath.row]
                cell.textLabel?.text = friend?.name
            }
            
        default:
            break
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NameInputViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        textField.text = cell?.textLabel?.text
        newFriendName = cell?.textLabel?.text
        
        moveToNextInputView()
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate

extension NameInputViewController: UITextFieldDelegate {
    private func initTextField() {
        nameTextField.addBottomLine(height: 1.0, color: UIColor.lightGray)
        
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addHolidayAtHome:
            textField.placeholder = "졸업식"
        case .addUpcomingEventAtHome,
             .addHistoryAtHoliday,
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
             .addHistoryAtHoliday,
             .addUpcomingEventAtHome:
            newFriendName = textField.text
        default:
            newHolidayName = textField.text
        }
        
        view.endEditing(true)
        return true
    }
}

// MARK: - UIGestureRecognizerDelegate

extension NameInputViewController: UIGestureRecognizerDelegate {
    private func initTapGesture() {
        let viewTapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
        
        viewTapGesture.delegate = self
        background.addGestureRecognizer(viewTapGesture)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension NameInputViewController: DatabaseManagerClient {
    func setDatabaseManager(_ manager: DatabaseManager) {
        databaseManager = manager
    }
}
