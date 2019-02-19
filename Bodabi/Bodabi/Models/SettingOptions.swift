//
//  SettingOptions.swift
//  Bodabi
//
//  Created by jaehyeon lee on 27/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation

enum SettingOptions: Int, CaseIterable {
    case question
    case notification
    case contact
    case facebook
    
    func description() -> String {
        switch self {
        case .question:
            return "문의하기"
        case .notification:
            return "알림"
        case .contact:
            return "연락처 연동"
        case .facebook:
            return "페이스북 페이지"
        }
    }
}
