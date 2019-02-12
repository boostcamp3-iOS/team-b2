//
//  Character+Unicode.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 12..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Foundation

extension Character {
    var unicode: uint {
        return UnicodeScalar(String(self))?.value ?? uint()
    }
    
    var isConsonant: Bool {
        if self.unicode < 0x3131 || self.unicode > 0x314E {
            return false
        }
        return true
    }
    
    var consonantIndex: Int {
        let consonantArray: [Character] = [ "ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ",
                                            "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ" ]
        return consonantArray.index(of: self) ?? 0
    }
    
    var isHangul: Bool {
        if self.unicode < 0xac00 || self.unicode > 0xd7a3 {
            return false
        }
        return true
    }
    
    var choseongCode: uint {
        guard isHangul else { return uint() }
        return ((self.unicode - 0xac00) / 28) / 21
    }
    
    var jungseongCode: uint {
        guard isHangul else { return uint() }
        return ((self.unicode - 0xac00) / 28) % 21
    }
    
    var jongseongCode: uint {
        guard isHangul else { return uint() }
        return (self.unicode - 0xac00) % 28
    }
    
    func isContainSyllable(compare character: Character) -> Bool {
        if character.isConsonant {
            return character.consonantIndex == self.choseongCode
        }
        
        if character.isHangul {
            if character.jongseongCode == 0 {
                if self.jongseongCode == 0 {
                    return character == self
                }
                return character.unicode == (self.unicode - self.jongseongCode)
            }
            return character == self
        }
        
        return false
    }
}
