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
    @IBOutlet weak var semiGuideLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var bottomConstriant: NSLayoutConstraint!
    @IBOutlet weak var heightConstriant: NSLayoutConstraint!
    @IBOutlet weak var firstTagLabel: UILabel!
    @IBOutlet weak var secondTagLabel: UILabel!
    @IBOutlet weak var thirdTagLabel: UILabel!
    @IBOutlet weak var firstTagIcon: UIView!
    @IBOutlet weak var secondTagIcon: UIView!
    @IBOutlet weak var thirdTagIcon: UIView!
    @IBOutlet weak var tagImageView: UIImageView!
    @IBOutlet weak var tagButton: UIButton!
    
    // MARK: - Properties
    
    public weak var delegate: HolidayInputViewController?
    public var entryRoute: EntryRoute!
    public var inputData: InputData! {
        didSet {
            guard nextButton != nil else { return }
            setNextButton()
        }
    }
    public var isRelationInput: Bool?
    private var databaseManager: CoreDataManager!
    private var friends: [Friend]?
    private var myRelations: [String]?
    private var myHolidays: [String]?
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
            initTagView()
        }
    }
    
    // MARK: - Lifecycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        initKeyboard()
        initGuideLabelText()
        initSemiGuideLabelText()
        initNavigationBar()
        initTextField()
        initNextButton()
        initTapGesture()
        initTagView()
        initTagImageView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
            fetchDefaultData()
        case .addUpcomingEventAtHome,
             .addHistoryAtHoliday,
             .addFriendAtFriends:
            fetchFriend()
        default:
            break
        }
    }
    
    private func fetchDefaultData() {
        guard let isRelationInput = isRelationInput else { return }
        if isRelationInput {
            if let defaultRelation = UserDefaults.standard.array(forKey: DefaultsKey.defaultRelation) as? [String] {
                myRelations = defaultRelation
            }
        } else {
            if let defaultHoliday = UserDefaults.standard.array(forKey: DefaultsKey.defaultHoliday) as? [String] {
                myHolidays = defaultHoliday
            }
        }
    }
    
    private func fetchFriend() {
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)

        databaseManager.fetch(type: Friend.self, sortDescriptor: sortDescriptor) { [weak self] (result) in
            switch result {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(friends):
                self?.friends = friends
                self?.tableView.reloadData()
            }
        }
    }
    
    private func initTableView() {
        tableView.delegate = self; tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "defaultCell")
    }
    
    private func initTagImageView() {
        guard let entryRoute = entryRoute else { return }
        switch entryRoute {
        case .addHolidayAtHome:
            tagButton.isHidden = true
            tagImageView.isHidden = true
        default:
            tagButton.isHidden = false
            tagImageView.isHidden = false
        }
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
            guard let isRelationInput = isRelationInput else { return }
            if isRelationInput {
                guideLabel.text = "새로운 관계 또는\n이름을 입력해주세요"
            } else {
                guideLabel.text = "새로운 경조사의\n이름을 입력해주세요"
            }
        case .addUpcomingEventAtHome,
             .addHistoryAtHoliday,
             .addFriendAtFriends:
            guideLabel.text = "친구의 이름이\n무엇인가요?"
        default:
            break
        }
    }
    
    private func initSemiGuideLabelText() {
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addHolidayAtHome:
            guard let isRelationInput = isRelationInput else { return }
            if isRelationInput {
                semiGuideLabel.text = "해당하는 관계 또는 이름이 이미 있다면 아래에서 선택해주세요"
            } else {
                semiGuideLabel.text = "해당하는 경조사가 이미 있다면 아래에서 선택해주세요"
            }
        case .addUpcomingEventAtHome,
             .addHistoryAtHoliday,
             .addFriendAtFriends:
            semiGuideLabel.text = "해당하는 분이 이미 있다면 아래에서 선택해주세요"
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
        guard let newFriendName = newFriendName else { return }
        let searchedFriends = friends?.filter { friend in
            friend.name?.contains(search: newFriendName) ?? false
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
        if let newHolidayName = newHolidayName, isUniqueName(with: newHolidayName) {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.mainColor
        } else if let newFriendName = newFriendName, isUniqueName(with: newFriendName) {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.mainColor
        } else if let newFriendName = newFriendName, !isUniqueName(with: newFriendName), isUniqueTags(from: newFriendName) {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.mainColor
        } else {
            initNextButton()
        }
    }
    
    private func isSame(_ newTags: [String], with friendTags: [String]) -> Bool {
        guard newTags.count == friendTags.count else {
            return false
        }
        
        let sortNewTags = newTags.sorted()
        let sortFriendTags = friendTags.sorted()
        
        for i in 0..<sortNewTags.count {
            if sortNewTags[i] != sortFriendTags[i] {
                return false
            }
        }

        return true
    }
    
    private func isUniqueTags(from newName: String) -> Bool {
        guard newName != "" else { return false }
        guard let newTags = inputData.tags else { return false }
        guard let searchedFriends = searchedFriends else { return true }
        
        var isUnique: Bool = true
        if searchedFriends.count == 0 { isUnique = false }
        searchedFriends.forEach { (friend) in
            if friend.name == newName, let friendTags = friend.tags {
                if isSame(newTags, with: friendTags) {
                    isUnique = false
                }
            } else if friend.tags == nil, newTags.count == 0{
                isUnique = false
            }
        }

        return isUnique
    }
    
    private func isUniqueName(with name: String) -> Bool {
        guard name != "" else { return false }
        guard let isRelationInput = isRelationInput else { return false }
        guard let entryRoute = entryRoute else { return false }
        var isUnique: Bool = true
        
        switch entryRoute {
        case .addHolidayAtHome:
            if isRelationInput {
                myRelations?.forEach {
                    if $0 == name {
                        isUnique = false
                    }
                }
            } else {
                myHolidays?.forEach {
                    if $0 == name {
                        isUnique = false
                    }
                }
            }
        case .addFriendAtFriends,
             .addHistoryAtHoliday,
             .addUpcomingEventAtHome:
            friends?.forEach {
                if $0.name == name {
                   isUnique = false
                }
            }
        default:
            break
        }
        
        return isUnique
    }
    
    private func moveToNextInputView(isNewData: Bool) {
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addHolidayAtHome:
            if isNewData {
                if let isRelationInput = isRelationInput, isRelationInput {
                    guard let newHolidayName = newHolidayName else { return }
                    delegate?.myRelations?.insert(newHolidayName, at: 1)
                    dismiss(animated: true, completion: nil)
                } else {
                    guard let newHolidayName = newHolidayName else { return }
                    delegate?.myHolidays?.insert(newHolidayName, at: 1)
                    dismiss(animated: true, completion: nil)
                }
            } else {
                dismiss(animated: true, completion: nil)
            }
        case .addUpcomingEventAtHome:
            // Fix write 중복 데이터
            let viewController = storyboard(.input)
                .instantiateViewController(ofType: HolidayInputViewController.self)
            
            inputData?.name = newFriendName
            inputData?.isNewData = isNewData
            
            viewController.entryRoute = entryRoute
            viewController.inputData = inputData
            viewController.isRelationInput = false
            viewController.setDatabaseManager(databaseManager)
            navigationController?.pushViewController(viewController, animated: true)
        case .addHistoryAtHoliday:
            let viewController = storyboard(.input)
                .instantiateViewController(ofType: ItemInputViewController.self)
            
            viewController.setDatabaseManager(databaseManager)
            viewController.entryRoute = entryRoute
            
            inputData?.isNewData = isNewData
            inputData?.name = newFriendName
            viewController.inputData = inputData
            navigationController?.pushViewController(viewController, animated: true)
        case .addFriendAtFriends:
            // Fix write 중복 데이터
            inputData?.name = newFriendName
            inputData?.isNewData = isNewData
            
            guard let inputData = inputData else { return }
            InputManager.write(context: databaseManager.viewContext, entryRoute: entryRoute, data: inputData)
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    
    private func initTagView() {
        firstTagIcon.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        secondTagIcon.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        thirdTagIcon.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        firstTagLabel.text = ""
        secondTagLabel.text = ""
        thirdTagLabel.text = ""
        inputData.tags = nil
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
        moveToNextInputView(isNewData: true)
    }
    
    @IBAction func touchUpTagButton(_ sender: UIButton) {
        let viewController = storyboard(.tag)
            .instantiateViewController(ofType: TagViewController.self)
        viewController.delegate = self
        present(viewController, animated: true, completion: nil)
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
            guard let isRelationInput = isRelationInput else { return 0 }
            if isRelationInput {
                if let myRelations = myRelations {
                    return myRelations.count - 1
                }
            } else {
                if let myHolidays = myHolidays {
                    return myHolidays.count - 1
                }
            }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "InputFriendViewCell", for: indexPath) as? InputFriendViewCell
        
        guard let entryRoute = entryRoute else { return UITableViewCell() }
        
        switch entryRoute {
        case .addHolidayAtHome:
            guard let isRelationInput = isRelationInput else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
            if isRelationInput {
                cell.textLabel?.text = myRelations?[indexPath.row + 1]
            } else {
                cell.textLabel?.text = myHolidays?[indexPath.row + 1]
            }
            return cell
        case .addUpcomingEventAtHome,
             .addHistoryAtHoliday,
             .addFriendAtFriends:
            if newFriendName == nil || newFriendName == "" {
                let friend = friends?[indexPath.row]
                cell?.friend = friend
            } else {
                let friend = searchedFriends?[indexPath.row]
                cell?.friend = friend
            }
            
        default:
            break
        }
        
        return cell ?? UITableViewCell()
    }
}

// MARK: - UITableViewDelegate

extension NameInputViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let entryRoute = entryRoute else { return }
        switch entryRoute {
        case .addHolidayAtHome:
            dismiss(animated: true, completion: nil)
        default:
            let cell = tableView.cellForRow(at: indexPath) as? InputFriendViewCell
            
            textField.text = cell?.nameLabel.text
            newFriendName = cell?.nameLabel.text
            inputData.tags = cell?.friend?.tags
            
            if let tags = cell?.friend?.tags {
                bind(tags)
            } else {
                initTagView()
            }
            moveToNextInputView(isNewData: false)
            view.endEditing(true)
        }
    }
}

// MARK: - UITextFieldDelegate

extension NameInputViewController: UITextFieldDelegate {
    private func initTextField() {
        nameTextField.addBottomLine(height: 1.0, color: UIColor.lightGray)
        
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addHolidayAtHome:
            guard let isRelationInput = isRelationInput else { return }
            
            if isRelationInput {
                textField.placeholder = "동생"
            } else {
                textField.placeholder = "졸업식"
            }
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

extension NameInputViewController: CoreDataManagerClient {
    func setDatabaseManager(_ manager: CoreDataManager) {
        databaseManager = manager
    }
}

extension NameInputViewController: BindDataDelegate {
    func bind(_ data: [String]) {
        initTagView()
        
        guard data.count != 0 else { return }
        
        inputData?.tags = data
        
        let tags = Array(data.reversed())
        if tags.count >= 1 {
            thirdTagLabel.text = tags[0]
            thirdTagIcon.backgroundColor = Tag.type(of: tags[0])?.color
        }
        if tags.count >= 2 {
            secondTagLabel.text = tags[1]
            secondTagIcon.backgroundColor = Tag.type(of: tags[1])?.color
        }
        if tags.count == 3 {
            firstTagLabel.text = tags[2]
            firstTagIcon.backgroundColor = Tag.type(of: tags[2])?.color
        }
    }
}
