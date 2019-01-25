//
//  UIViewController+Alert.swift
//  Bodabi
//
//  Created by Kim DongHwan on 25/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

extension UIViewController {
    func addAlert(_ message: String, completion: (()->Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .cancel) { (_) in
            completion?()
        }
        alert.addAction(okAction)
        
        self.present(alert, animated: true)
    }
}
