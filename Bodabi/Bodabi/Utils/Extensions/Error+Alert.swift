//
//  Error+Alert.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 21..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Foundation

extension Error {
    func loadErrorAlert(title: String = "",
                        alertHandler: ((BodabiAlertController) -> Void)? = nil,
                        completion: (() -> Void)? = nil) {
        let alert = BodabiAlertController(
            title: self is ContactError ? (self as? ContactError)?.title : title,
            message: self.localizedDescription,
            type: nil,
            style: .Alert
        )
        alertHandler?(alert)
        alert.addButton(title: "확인") {
            completion?()
        }
        alert.show()
    }
}
