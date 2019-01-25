//
//  UIViewController+ActionSheet.swift
//  Bodabi
//
//  Created by Kim DongHwan on 25/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

extension UIViewController {
    func addActionSheet(title: String? = nil, message: String? = nil, actions: [String], handler: ((UIAlertAction)->Void)? = nil) {
        let alertController: UIAlertController
        alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        for action in actions {
            let someAction: UIAlertAction
            someAction = UIAlertAction(title: action, style: UIAlertAction.Style.default, handler: handler)
            
            alertController.addAction(someAction)
        }
        
        let cancelAction: UIAlertAction
        cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: handler)
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
}
