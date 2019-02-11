//
//  SettingOptions.swift
//  Bodabi
//
//  Created by jaehyeon lee on 27/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation

enum SettingOptions: Int, CaseIterable {
    case backup
    case review
    case question
    
    func description() -> String {
        switch self {
        case .backup:
            return "백업"
        case .review:
            return "리뷰 남기기"
        case .question:
            return "문의하기"
        }
    }
}
