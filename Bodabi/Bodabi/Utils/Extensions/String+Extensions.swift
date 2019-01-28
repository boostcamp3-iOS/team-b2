//
//  String+Extensions.swift
//  Bodabi
//
//  Created by jaehyeon lee on 27/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation

extension String {
    func isFinalConsonant() -> Bool {
        guard let lastWord = self.last else {
            return false
        }
        guard let lastSyllable = UnicodeScalar(String(lastWord))?.value else {
            return false
        }
        let finalConsonant: Bool = (lastSyllable - 0xac00) % 28 != 0
        return finalConsonant
    }
    
    func isFinalConsonantFourth() -> Bool {
        guard let lastWord = self.last else {
            return false
        }
        guard let lastSyllable = UnicodeScalar(String(lastWord))?.value else {
            return false
        }
        let finalConsonantFourth: Bool = (lastSyllable - 0xac00) % 28 == 8
        return finalConsonantFourth
    }
    
    func addForSuffix() -> String {
        if !self.isFinalConsonant() || self.isFinalConsonantFourth() {
            return self + "로"
        }
        return self + "으로"
    }
    
    func addObjectSuffix() -> String {
        let suffix = self.isFinalConsonant() ? "을" : "를"
        return self + suffix
    }
    
    func addSubjectSuffix() -> String {
        let suffix = self.isFinalConsonant() ? "이" : "가"
        return self + suffix
    }
}
