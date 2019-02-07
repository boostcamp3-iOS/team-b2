//
//  Notification+Extensions.swift
//  Bodabi
//
//  Created by jaehyeon lee on 03/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation

extension Notification {
    
    // MARK: - Helper
    
    var dday: Int {
        if let date = self.event?.date {
            return date.offsetFrom(date: Date())
        }
        return 0
    }
    
    var sentence: String {
        if let name = self.event?.friend?.name,
            let title = self.event?.title?.addObjectSuffix() {
            switch dday {
            case 0:
                return "\(name)님의 지난 \(title) 축하해주셨나요?"
            default:
                return "\(dday)일 뒤 \(name)님의 \(title) 축하해주세요!"
            }
        }
        return "알림 정보를 불러올 수 없습니다"
    }
}
