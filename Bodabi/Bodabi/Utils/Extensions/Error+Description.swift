//
//  Error+Description.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 21..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Foundation

extension ContactError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .accessFailed(errorMessage: let message):
            return NSLocalizedString("Contact access failed : \(message)", comment: "Contact error")
        case .accessDeniedError:
            return NSLocalizedString("연락처 접근이 허용되지 않았습니다.\n설정에서 접근 권한을 허용해주세요.",
                                     comment: "Contact error")
        case .loadFailed(errorMessage: let message):
            return NSLocalizedString("Contact load failed : \(message)", comment: "Contact error")
        }
    }
}
