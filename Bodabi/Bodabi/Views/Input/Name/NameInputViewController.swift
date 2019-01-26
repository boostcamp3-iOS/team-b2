//
//  NameInputViewController.swift
//  Bodabi
//
//  Created by Kim DongHwan on 26/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class NameInputViewController: UIViewController {
    
    weak var delegate: HomeViewController?
    var entryRoute: EntryRoute!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.clear()
    }
    
    @IBAction func dismissInputView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
