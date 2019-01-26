//
//  ItemInputViewController.swift
//  Bodabi
//
//  Created by Kim DongHwan on 26/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class ItemInputViewController: UIViewController {
    
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
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var itemTypeLabel: UILabel!
    @IBOutlet weak var itemInputTextField: UITextField!
    @IBOutlet weak var usedItemCollectionView: UICollectionView!
    
    weak var delegate: HomeViewController?
    var entryRoute: EntryRoute!
    
    var item: Item? {
        didSet {
            setItemInputView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.clear()
    }
    
    private func setItemInputView() {
        itemTypeLabel.text = item?.text
        itemInputTextField.placeholder = item?.placeholder
    }
    
    @IBAction func switchItem(_ sender: UISegmentedControl) {
        item = sender.selectedSegmentIndex == 0 ? .cache : .gift
    }
    
    @IBAction func dismissInputView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
