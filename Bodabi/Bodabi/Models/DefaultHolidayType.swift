//
//  DefaultHolidayType.swift
//  Bodabi
//
//  Created by jaehyeon lee on 22/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

enum DefaultHolidayType: CaseIterable {
    
    case wedding
    case birthday
    case babyAnniversary
    case funeral
    case enterance
    case graduation
    case babyBorn
    case etcAnniversary
    
    var holidayImage: UIImage {
        switch self {
        case .wedding: return #imageLiteral(resourceName: "wedding")
        case .birthday: return #imageLiteral(resourceName: "birthday")
        case .babyAnniversary: return #imageLiteral(resourceName: "babyborn")
        case .funeral: return #imageLiteral(resourceName: "funeral")
        default: return #imageLiteral(resourceName: "ic_placeholder")
        }
    }
    
    var notificationImage: UIImage {
        switch self {
        case .wedding: return #imageLiteral(resourceName: "ic_noti_wedding")
        case .birthday: return #imageLiteral(resourceName: "ic_noti_birthday")
        case .babyAnniversary: return #imageLiteral(resourceName: "ic_noti_baby")
        case .enterance: return #imageLiteral(resourceName: "ic_noti_school")
        case .graduation: return #imageLiteral(resourceName: "ic_noti_graduation")
        case .babyBorn: return #imageLiteral(resourceName: "ic_noti_bitrh")
        default: return #imageLiteral(resourceName: "ic_noti_default")
        }
    }
    
    var title: String {
        switch self {
        case .wedding: return "결혼"
        case .birthday: return "생일"
        case .babyAnniversary: return "돌잔치"
        case .funeral: return "장례"
        case .enterance: return "입학"
        case .graduation: return "졸업"
        case .babyBorn: return "출산"
        default: return "기타 기념일"
        }
    }
    
    var color: UIColor {
        switch self {
        case .wedding: return #colorLiteral(red: 0.9389655272, green: 0.7708361039, blue: 0.7560511435, alpha: 1)
        case .birthday: return #colorLiteral(red: 0.7798443437, green: 0.8282508254, blue: 0.8924162984, alpha: 1)
        case .babyAnniversary: return #colorLiteral(red: 0.9674142003, green: 0.8236435652, blue: 0.6889871359, alpha: 1)
        case .funeral: return #colorLiteral(red: 0.5532687306, green: 0.3923246861, blue: 0.4829044938, alpha: 1)
        case .enterance: return #colorLiteral(red: 0.8807150722, green: 0.3545673192, blue: 0.4221659899, alpha: 1)
        case .graduation: return #colorLiteral(red: 0.8719369769, green: 0.6207509637, blue: 0.6524723172, alpha: 1)
        case .babyBorn: return #colorLiteral(red: 0.5707006454, green: 0.6276458502, blue: 0.7518854737, alpha: 1)
        default: return #colorLiteral(red: 0.961987555, green: 0.7720394135, blue: 0.4948675036, alpha: 1)
        }
    }
    
    static func parse(with holiday: String?) -> DefaultHolidayType {
        guard let holiday = holiday else { return DefaultHolidayType.etcAnniversary }
        for type in DefaultHolidayType.allCases {
            if holiday.contains(search: type.title) {
                return type
            }
        }
        return DefaultHolidayType.etcAnniversary
    }
}
