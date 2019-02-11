//
//  History+Extensions.swift
//  Bodabi
//
//  Created by jaehyeon lee on 03/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation

extension History {
    
    // MARK: - Helper
    
    var giveSentence: String {
        if let item = self.item, let cash = Int(item) {
            let formattedCash = String(cash).insertComma()
            return "\(self.friend?.name ?? "")님께 \(self.holiday?.addForSuffix() ?? "") \(formattedCash ?? "")원을 전달했습니다"
        } else {
            return "\(self.friend?.name ?? "")님께 \(self.holiday?.addForSuffix() ?? "") \(self.item?.addObjectSuffix() ?? "") 전달했습니다"
        }
    }
    var takeSentence: String {
        if let item = self.item, let cash = Int(item) {
            let formattedCash = String(cash).insertComma()
            return "\(self.friend?.name ?? "")님께서 \(self.holiday?.addForSuffix() ?? "") \(formattedCash ?? "")원을 전달해주셨습니다"
        } else {
            return "\(self.friend?.name ?? "")님께서 \(self.holiday?.addForSuffix() ?? "") \(self.item?.addObjectSuffix() ?? "") 전달해주셨습니다"
        }
    }
}
