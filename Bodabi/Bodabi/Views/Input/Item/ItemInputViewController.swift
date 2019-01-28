//
//  ItemInputViewController.swift
//  Bodabi
//
//  Created by Kim DongHwan on 26/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class ItemInputViewController: UIViewController {
    
    @IBOutlet weak var itemTypeLabel: UILabel!
    @IBOutlet weak var itemInputTextField: UITextField!
    @IBOutlet weak var usedItemCollectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    
    enum Item {
        case cache
        case gift
        
        var text: String {
            switch self {
            case .cache:
                return "금액"
            case .gift:
                return "선물"
            }
        }
        
        var placeholder: String {
            switch self {
            case .cache:
                return "원"
            case .gift:
                return "기프티콘"
            }
        }
    }
    
    weak var delegate: HomeViewController?
    var entryRoute: EntryRoute!
    
    var item: Item = .cache {
        didSet {
            setItemInputView()
            setKeyboardType()
        }
    }
    
    var myItem: String? {
        didSet {
            setNextButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initNextButton()
        initTapGesture()
    }
    
    private func initNavigationBar() {
        self.navigationController?.navigationBar.clear()
        
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_backButton"), style: .plain, target: self, action: #selector(popCurrentInputView(_:)))
        
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    private func initNextButton() {
        nextButton.setTitle("다음", for: .normal)
        nextButton.backgroundColor = UIColor.offColor
        nextButton.isEnabled = false
    }
    
    private func setNextButton() {
        if myItem == "" {
            initNextButton()
        } else {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.mainColor
        }
    }
    
    private func setItemInputView() {
        itemTypeLabel.text = item.text
        itemInputTextField.placeholder = item.placeholder
        
        itemInputTextField.text = ""
        initNextButton()
    }
    
    private func setKeyboardType() {
        if item.text == "금액" {
            itemInputTextField.keyboardType = .numberPad
        } else {
            itemInputTextField.keyboardType = .default
        }
    }
    
    @IBAction func switchItem(_ sender: UISegmentedControl) {
        item = sender.selectedSegmentIndex == 0 ? .cache : .gift
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
    
    @objc func popCurrentInputView(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dismissInputView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ItemInputViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        myItem = textField.text
        self.view.endEditing(true)
        return true
    }
}

extension ItemInputViewController: UIGestureRecognizerDelegate {
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
