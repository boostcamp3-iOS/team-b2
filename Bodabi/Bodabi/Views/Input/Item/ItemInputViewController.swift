//
//  ItemInputViewController.swift
//  Bodabi
//
//  Created by Kim DongHwan on 26/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class ItemInputViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var itemTypeLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var bottomConstriant: NSLayoutConstraint!
    @IBOutlet weak var heightConstriant: NSLayoutConstraint!
    
    // MARK: - Property

    public weak var delegate: HomeViewController?
    
    public var inputData: InputData?
    public var entryRoute: EntryRoute!
    public var databaseManager: DatabaseManager!
    
    private var originalBottomConstraint: CGFloat = 0.0
    private var originalHeightConstraint: CGFloat = 0.0
    private var item: Item = .cash(amount: "") {
        didSet {
            setNextButton()
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initKeyboard()
        initCollectionView()
        initNavigationBar()
        initNextButton()
        initTapGesture()
        initTextField()
        initData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    // MARK: - Initialization
    
    private func initData() {
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addHolidayAtHome:
            print("addFriendAtHoliday")
        case .addUpcomingEventAtHome:
            print("addUpcomingEventAtHome")
        case .addHistoryAtHoliday:
            print("addHistoryAtHoliday")
        case .addFriendAtFriends:
            print("addFriendAtFriends")
        default:
            break
        }
    }
    
    private func initCollectionView() {
        collectionView.delegate = self; collectionView.dataSource = self
        collectionView.register(ItemViewCell.self)
        collectionView.collectionViewLayout = ItemCollectionViewFlowLayout()
    }
    
    private func initTextField() {
        textField.delegate = self
        textField.addBottomLine(height: 1.0, color: UIColor.lightGray)
    }
    
    private func initKeyboard() {
        originalBottomConstraint = bottomConstriant.constant
        originalHeightConstraint = heightConstriant.constant
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    private func initNavigationBar() {
        navigationController?.navigationBar.clear()
        
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_backButton"), style: .plain, target: self, action: #selector(popCurrentInputView(_:)))
        
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func initNextButton() {
        nextButton.setTitle("다음", for: .normal)
        nextButton.backgroundColor = UIColor.offColor
        nextButton.isEnabled = false
    }
    
    // MARK: - Setup
    
    private func setNextButton() {
        if item.value == "" {
            initNextButton()
            return
        }
        
        nextButton.isEnabled = true
        nextButton.backgroundColor = UIColor.mainColor
    }
    
    private func setTextField() {
        textField.text = ""
        textField.placeholder = item.placeholder
    }
    
    private func setItemLabel() {
        itemTypeLabel.text = item.text
    }
    
    private func setKeyboardType() {
        view.endEditing(true)

        if item.text == "금액" {
            textField.keyboardType = .numberPad
        } else {
            textField.keyboardType = .default
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func switchItem(_ sender: UISegmentedControl) {
        item = sender.selectedSegmentIndex == 0 ? .cash(amount: "") : .gift(name: "")
    
        setItemLabel()
        setKeyboardType()
        setTextField()
        
        collectionView.reloadData()
    }
    
    @IBAction func textFieldDidChanging(_ sender: UITextField) {
        if item.text == "금액" {
            item = .cash(amount: sender.text ?? "")
        } else {
            item = .gift(name: sender.text ?? "")
        }
    }
    
    @IBAction func touchUpNextButton(_ sender: UIButton) {
        guard var inputData = inputData else { return }
        
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addHistoryAtFriendHistory:
            let viewController = storyboard(.input)
                .instantiateViewController(ofType: DateInputViewController.self)
            viewController.setDatabaseManager(databaseManager)
            viewController.entryRoute = entryRoute
            viewController.inputData = inputData
            navigationController?.pushViewController(viewController, animated: true)
            print("addHistoryAtFriendHistory")
        case .addHistoryAtHoliday:
            inputData.item = item
            InputManager.write(context: databaseManager.viewContext, entryRoute: entryRoute, data: inputData)
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    
    @IBAction func dismissInputView(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Objc
    
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

// MARK: - UICollectionViewDataSource

extension ItemInputViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return item.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(ItemViewCell.self, for: indexPath)
        
        switch item {
        case .cash:
            cell.itemLabel.text = "+" + item.list[indexPath.item]
        case .gift:
            cell.itemLabel.text = item.list[indexPath.item]
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ItemInputViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var selectedItem = item.list[indexPath.item]
        
        switch item {
        case let .cash(amount):
            selectedItem = amount.plus(with: selectedItem) ?? ""
            item = .cash(amount: selectedItem)
            guard let currentText = selectedItem.insertComma() else { return }
            textField.text = currentText + "원"
        case .gift:
            item = .gift(name: selectedItem)
            textField.text = selectedItem
        }
        
        view.endEditing(true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ItemInputViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect.zero)
        
        label.text = item.list[indexPath.item]
        label.sizeToFit()
        
        return CGSize(width: label.frame.width + 32, height: 32)
    }
}

// MARK: - UITextFieldDelegate

extension ItemInputViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let currentText = textField.text
        
        item = itemTypeLabel.text == "금액" ? .cash(amount: currentText ?? "") : .gift(name: currentText ?? "")
        
        view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let preText = textField.text else { return true }
        switch item {
        case .cash:
            guard var currentText = preText.insertComma(with: string, range: range) else {
                return true
            }
            
            item = .cash(amount: currentText.deleteComma())
            
            if currentText != "" {
                currentText += "원"
            }
            
            textField.text = currentText
            
            return false
        default:
            return true
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ItemInputViewController: UIGestureRecognizerDelegate {
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

extension ItemInputViewController: DatabaseManagerClient {
    func setDatabaseManager(_ manager: DatabaseManager) {
        databaseManager = manager
    }
}
