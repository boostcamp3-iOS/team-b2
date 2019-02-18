//
//  IndexAlertViewController.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 13..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class IndexAlertViewController: UIViewController {

    @IBOutlet weak var indexLabel: UILabel!
    
    public var indexTitle: Character?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let title = indexTitle else { return }
        indexLabel.text = String(title)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.dismiss(animated: true, completion: nil)
    }

}
