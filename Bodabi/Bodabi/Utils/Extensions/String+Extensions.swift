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
        guard let number = Int(self) else { return self }
        
        let withSeparator: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.groupingSeparator = ","
            formatter.numberStyle = .decimal
            return formatter
        }()
        
        return withSeparator.string(from: number as NSNumber)
    }
    
    func deleteComma() -> String {
        let deletedString = self.filter {
            $0 != ","
        }
        print(deletedString)
        return deletedString
    }
    
    func insertComma(with string: String?, range: NSRange?) -> String? {
        var currentText = self
        
        if currentText.last == "원" {
            currentText.popLast()
        }
        
        currentText = currentText.deleteComma()
        
        // backButton이 아니면
        if range?.length == 0 {
            currentText += string ?? ""
            
            if let insertedCommaText = currentText.insertComma() {
                currentText = insertedCommaText
            } else {
                return nil
            }
            
//            currentText += suffix ?? ""
        } else {
            currentText.popLast()
            
            if currentText != "" {
                if let insertedCommaText = currentText.insertComma() {
                    currentText = insertedCommaText
                }
                
//                currentText += suffix ?? ""
            }
        }
        
        return currentText
    }
}
