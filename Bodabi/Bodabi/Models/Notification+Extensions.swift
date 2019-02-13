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
    
    var sentence: String {
        if let name = self.event?.friend?.name,
            let title = self.event?.title?.addObjectSuffix(),
            let dday = self.event?.dday {
            if dday == 0 {
                return "오늘 \(name)님의 \(title) 축하해주세요!"
            } else if dday == 1 {
                return "내일 \(name)님의 \(title) 축하해주세요!"
            } else if dday > 0 {
                return "\(dday)일 뒤 \(name)님의 \(title) 축하해주세요!"
            } else {
                return "\(name)님의 \(title) 축하해주셨나요?"
            }
        }
        return "알림 정보를 불러올 수 없습니다"
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.isRead = false
    }
}
