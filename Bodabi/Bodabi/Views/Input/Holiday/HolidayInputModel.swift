//
//  HolidayModel.swift
//  Bodabi
//
//  Created by Kim DongHwan on 21/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation

enum CellType {
    case holiday
    case relation
    
    var userDefaultKey: String {
        switch self {
        case .relation:
            return "defaultRelation"
        case .holiday:
            return "defaultHoliday"
        }
    }
    
    var guideLabel: String {
        switch self {
        case .relation:
            return "누구의 경조사를\n추가하시겠어요?"
        case .holiday:
            return "어떤 경조사를\n추가하시겠어요?"
        }
    }
    
    var guideLabelAtNameInputView: String {
        switch self {
        case .relation:
            return "새로운 관계 또는\n이름을 입력해주세요"
        case .holiday:
            return "새로운 경조사의\n이름을 입력해주세요"
        }
    }
    
    var semiGuideLabelAtNameInputView: String {
        switch self {
        case .relation:
            return "해당하는 관계 또는 이름이 이미 있다면 아래에서 선택해주세요"
        case .holiday:
            return "해당하는 경조사가 이미 있다면 아래에서 선택해주세요"
        }
    }
    
    var placeholderAtNameInputView: String {
        switch self {
        case .relation:
            return "동생"
        case .holiday:
            return "졸업식"
        }
    }
}
