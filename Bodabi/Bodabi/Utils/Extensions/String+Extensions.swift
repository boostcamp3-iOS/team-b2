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
    
    func insertComma() -> String? {
        let numberFormatter = NumberFormatter(); numberFormatter.numberStyle = .decimal
        
        if let _ = self.range(of: ".") {
            var numberArray = self.components(separatedBy: ".")
            if numberArray.count == 1 {
                var numberString = numberArray[0]
                if numberString.isEmpty {
                    numberString = "0"
                }
                guard let doubleValue = Double(numberString) else {
                    return self
                }
                return numberFormatter.string(from: NSNumber(value: doubleValue)) ?? self
            } else if numberArray.count == 2 {
                var numberString = numberArray[0]
                if numberString.isEmpty {
                    numberString = "0"
                }
                guard let doubleValue = Double(numberString) else {
                    return self
                }
                return (numberFormatter.string(from: NSNumber(value: doubleValue)) ?? numberString) + ".\(numberArray[1])"
            }
        } else {
            guard let doubleValue = Double(self) else {
                return self
            }
            return numberFormatter.string(from: NSNumber(value: doubleValue)) ?? self
        }
        return self
    }
    
    func deleteComma() -> String {
        let deletedString = self.filter {
            $0 != ","
        }
        print(deletedString)
        return deletedString
    }
}
