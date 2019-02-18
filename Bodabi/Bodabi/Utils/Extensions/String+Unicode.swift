//
//  String+Unicode.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 12..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Foundation

extension String {
    func contains(search text: String) -> Bool {
        let compareChars = text.map { $0 }
        let targetChars = self.map { $0 }
        
        var indexes: [Int] = []
        guard let compareFirstChar = compareChars.first else { return false }
        for (i, targetChar) in targetChars.enumerated()
            where targetChar.contains(syllable: compareFirstChar) {
                indexes.append(i)
        }
        
        for index in indexes where (index + compareChars.count) < targetChars.count + 1 {
            for (i, compareChar) in compareChars.enumerated() {
                guard targetChars[index + i].contains(syllable: compareChar) else  { break }
                if i == (compareChars.count - 1) {
                    return true
                }
            }
        }
        
        return false
    }
}
