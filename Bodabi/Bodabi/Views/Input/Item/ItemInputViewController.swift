//
//  ItemInputViewController.swift
//  Bodabi
//
//  Created by Kim DongHwan on 26/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class ItemInputViewController: UIViewController {
    
    // MARK: - @IBOutlets
    
    @IBOutlet weak var itemTypeLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var bottomConstriant: NSLayoutConstraint!
    @IBOutlet weak var heightConstriant: NSLayoutConstraint!
    
    // MARK: - Properties

    public weak var delegate: HomeViewController?
    public var entryRoute: EntryRoute!
    private var originalBottomConstraint: CGFloat = 0.0
    private var originalHeightConstraint: CGFloat = 0.0
    private var item: Item = .cash(amount: "") {
        didSet {
            setNextButton()
        }
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initKeyboard()
        initCollectionView()
        initNavigationBar()
        initNextButton()
        initTapGesture()
        initTextField()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    // MARK: - Initialization Methods
    
    private func initCollectionView() {
        collectionView.delegate = self; collectionView.dataSource = self
        collectionView.register(ItemViewCell.self)
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        collectionView.collectionViewLayout = layout
    }
    
    private func initTextField() {
        textField.delegate = self
        textField.addBottomLine(height: 1.0, color: UIColor.lightGray)
    }
    
    private func initKeyboard() {
        originalBottomConstraint = bottomConstriant.constant
        originalHeightConstraint = heightConstriant.constant
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChacnge(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChacnge(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChacnge(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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
    
    // MARK: - Setup Methods
    
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
    
    // MARK: - @IBActions
    
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
        let viewController = storyboard(.input)
            .instantiateViewController(ofType: DateInputViewController.self)
        
        viewController.entryRoute = entryRoute
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func dismissInputView(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - @objcs
    
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
        case var .cash(amount):
            selectedItem = amount.plus(with: selectedItem) ?? ""
            item = .cash(amount: selectedItem)
        case .gift:
            item = .gift(name: selectedItem)
        }
        
        guard let currentText = selectedItem.insertComma() else { return }
        textField.text = currentText + "원"
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

// MARK: - Type

extension ItemInputViewController {
    enum Item {
        case cash(amount: String)
        case gift(name: String)
        
        var text: String {
            switch self {
            case .cash:
                return "금액"
            case .gift:
                return "선물"
            }
        }
        
        var placeholder: String {
            switch self {
            case .cash:
                return "원"
            case .gift:
                return "기프티콘"
            }
        }
        
        var list: [String] {
            switch  self {
            case .cash:
                return ["10000", "30000", "50000", "70000", "100000", "200000"]
            case .gift:
                return ["꽃", "기프티콘", "냉장고", "전자레인지", "옷", "케이크", "화장품", "상품권"]
            }
        }
        
        var value: String {
            switch self {
            case let .cash(amount):
                return amount
            case let .gift(name):
                return name
            }
        }
    }
}
