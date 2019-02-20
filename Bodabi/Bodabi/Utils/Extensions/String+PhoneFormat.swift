//
//  String+PhoneFormat.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 19..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Foundation

extension String {
    public func toPhoneFormat() -> String {
        let phone = self.replacingOccurrences(of: "+82", with: "0")
        let regex = phone.range(of: "02")?.lowerBound.encodedOffset == 0 ?
            "(\\d{2})(\\d{3,4})(\\d{4})$" : "(\\d{2,3})(\\d{3,4})(\\d{4})$"
        return phone.replacingOccurrences(of: regex, with: "$1-$2-$3",
                                          options: .regularExpression, range: nil)
    }
}
