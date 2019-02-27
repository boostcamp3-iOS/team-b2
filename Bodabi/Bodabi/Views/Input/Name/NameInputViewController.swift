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
    
    public var entryRoute: EntryRoute!
    public var inputData: InputData! {
        didSet {
            guard nextButton != nil else { return }
            setNextButton()
        }
    }
    public var cellType: CellType!
    
    public var isRelationInput: Bool?
    private var coreDataManager: CoreDataManager!
    private var friends: [Friend]?
    private var cellData: [String]?
    private var searchedFriends: [Friend]? {
        didSet {
            tableView.reloadData()
        }
    }
    private var originalBottomConstraint: CGFloat = 0.0
    private var originalHeightConstraint: CGFloat = 0.0
    
    private var newDefaultData: String? {
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
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        initKeyboard()
        initGuideLabelText()
        initNavigationBar()
        initTextField()
        initNextButton()
        initTapGesture()
        initTagView()
        initTagImageView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    // MARK: - Initialization

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
            guideLabel.text = cellType.guideLabelAtNameInputView
            semiGuideLabel.text = cellType.semiGuideLabelAtNameInputView
        case .addUpcomingEventAtHome,
             .addHistoryAtHoliday,
             .addFriendAtFriends:
            guideLabel.text = "친구의 이름이\n무엇인가요?"
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
    
    // MARK: - Fetch
    
    private func fetchData() {
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
        guard let cellType = cellType else { return }
        
        if let data = UserDefaults.standard.array(forKey: cellType.userDefaultKey) as? [String] {
            cellData = data
        }
    }
    
    private func fetchFriend() {
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        coreDataManager.fetch(type: Friend.self, sortDescriptor: sortDescriptor) { [weak self] (result) in
            switch result {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(friends):
                self?.friends = friends
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Setup
    
    private func setTableView() {
        guard let newFriendName = newFriendName else { return }
        let searchedFriends = friends?.filter { friend in
            friend.name?.contains(search: newFriendName) ?? false
        }
        
        self.searchedFriends = searchedFriends
    }
    
    private func setGuideLabel() {
        if newDefaultData == "" || newFriendName == "" {
            initGuideLabelText()
        } else {
            guard let entryRoute = entryRoute else { return }
            
            switch entryRoute {
            case .addHolidayAtHome:
                let attributedString = NSMutableAttributedString()
                    .color(newDefaultData ?? "", fontSize: 25)
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
        if let newDefaultData = newDefaultData, isUniqueName(with: newDefaultData) {
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
        guard let searchedFriends = searchedFriends else { return true }
        
        var isUnique: Bool = true
        if searchedFriends.count == 0 { return false }
        searchedFriends.forEach { (friend) in
            if friend.name == newName, let friendTags = friend.tags, let newTags = inputData.tags {
                if isSame(newTags, with: friendTags) {
                    isUnique = false
                }
            } else if friend.tags == nil, inputData.tags == nil {
                isUnique = false
            }
        }

        return isUnique
    }
    
    private func isUniqueName(with name: String) -> Bool {
        guard name != "" else { return false }
        guard let entryRoute = entryRoute else { return false }
        
        var isUnique: Bool = true
        
        switch entryRoute {
        case .addHolidayAtHome:
            guard let cellData = cellData else { return false }
            cellData.forEach {
                if $0 == name {
                    isUnique = false
                }
            }
        case .addFriendAtFriends,
             .addHistoryAtHoliday,
             .addUpcomingEventAtHome:
            guard let friends = friends else { return false }
            friends.forEach {
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
                if let newDefaultData = newDefaultData, var cellData = cellData {
                    cellData.insert(newDefaultData, at: 1)
                    UserDefaults.standard.set(cellData, forKey: cellType.userDefaultKey)
                }
                dismiss(animated: true, completion: nil)
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
            viewController.cellType = .holiday
            viewController.setCoreDataManager(coreDataManager)
            navigationController?.pushViewController(viewController, animated: true)
        case .addHistoryAtHoliday:
            let viewController = storyboard(.input)
                .instantiateViewController(ofType: ItemInputViewController.self)
            
            viewController.setCoreDataManager(coreDataManager)
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
            InputManager.write(context: coreDataManager.viewContext, entryRoute: entryRoute, data: inputData)
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
            newDefaultData = sender.text
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
            let userInfo: NSDictionary = notification.userInfo! as NSDictionary
            let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
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
            guard let cellData = cellData else { return 0 }
            return cellData.count - 1
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
        guard let entryRoute = entryRoute else { return UITableViewCell() }
        
        switch entryRoute {
        case .addHolidayAtHome:
            guard let cellData = cellData else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
            
            cell.textLabel?.text = cellData[indexPath.row + 1]
            return cell
        case .addUpcomingEventAtHome,
             .addHistoryAtHoliday,
             .addFriendAtFriends:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InputFriendViewCell", for: indexPath) as? InputFriendViewCell else { return UITableViewCell() }
            
            if newFriendName == nil || newFriendName == "" {
                let friend = friends?[indexPath.row]
                cell.friend = friend
            } else {
                let friend = searchedFriends?[indexPath.row]
                cell.friend = friend
            }
            
            return cell
        default:
            return UITableViewCell()
        }
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
            guard let cell = tableView.cellForRow(at: indexPath) as? InputFriendViewCell else { return }
            
            textField.text = cell.nameLabel.text
            newFriendName = cell.nameLabel.text
            inputData.tags = cell.friend?.tags
            bind(cell.friend?.tags)
            
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
            guard let cellType = cellType else { return }
            textField.placeholder = cellType.placeholderAtNameInputView
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
            newDefaultData = textField.text
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
    func setCoreDataManager(_ manager: CoreDataManager) {
        coreDataManager = manager
    }
}

extension NameInputViewController: BindDataDelegate {
    func bind(_ data: [String]?) {
        
        guard let data = data, data.count != 0 else {
            initTagView()
            return
        }
        
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
