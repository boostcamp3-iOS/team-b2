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

    private let cashList: [String] = ["10000", "30000", "50000", "70000", "100000", "200000"]
    private let giftList: [String] = ["꽃", "기프티콘", "냉장고", "전자레인지", "옷", "케이크", "화장품", "상품권"]

    public weak var delegate: HomeViewController?
    public var entryRoute: EntryRoute!
    private var originalBottomConstraint: CGFloat = 0.0
    private var originalHeightConstraint: CGFloat = 0.0
    private var item: Item = .cash {
        didSet {
            setItemInputType()
            setKeyboardType()
            
            collectionView.reloadData()
        }
    }
    private var myItem: String? {
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
        if myItem == "" {
            initNextButton()
        } else {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.mainColor
        }
    }
    
    private func setItemInputType() {
        itemTypeLabel.text = item.text
        
        textField.placeholder = item.placeholder
        textField.text = ""
        
        initNextButton()
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
        item = sender.selectedSegmentIndex == 0 ? .cash : .gift
    }
    
    @IBAction func textFieldDidChanging(_ sender: UITextField) {
        myItem = sender.text
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
        switch item {
        case .cash:
            return cashList.count
        case .gift:
            return giftList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(ItemViewCell.self, for: indexPath)
        
        switch item {
        case .cash:
            if let insertedCommaString = cashList[indexPath.item].insertComma() {
                cell.itemLabel.text = "+" + insertedCommaString
            }
        case .gift:
            if let insertedCommaString = giftList[indexPath.item].insertComma() {
                cell.itemLabel.text = insertedCommaString
            }
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ItemInputViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ItemInputViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect.zero)
        
        switch item {
        case .cash:
            label.text = cashList[indexPath.item]
        case .gift:
            label.text = giftList[indexPath.item]
        }
        
        label.sizeToFit()
        
        return CGSize(width: label.frame.width + 32, height: 32)
    }
}

// MARK: - UITextFieldDelegate

extension ItemInputViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        myItem = textField.text
        view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var preText = textField.text else { return true }
        switch item {
        case .cash:
            if preText.last == "원" {
                preText.popLast()
            }
            
            preText = preText.deleteComma()
            
            if range.length == 0 {
                preText += string
                
                if let insertedCommaString = preText.insertComma() {
                    preText = insertedCommaString
                }
                
                preText += "원"
            } else {
                preText.popLast()
                
                if preText != "" {
                    if let insertedCommaString = preText.insertComma() {
                        preText = insertedCommaString
                    }
                    
                    preText += "원"
                }
            }
            
            textField.text = preText
            myItem = preText
            
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
        case cash
        case gift
        
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
    }
}
