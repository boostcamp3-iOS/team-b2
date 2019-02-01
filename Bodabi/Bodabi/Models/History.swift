//
//  History.swift
//  Bodabi
//
//  Created by jaehyeon lee on 25/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import Foundation

struct History {
    let id: Int
    let isTaken: Bool
    let holiday: String
    let date: Date
    let item: String
    
    // TODO: - Replace property to 'friendID' after database loading
    
    var friendName: String {
        return Friend.dummies[friendId].name
    }
    
    let friendId: Int
    
    // MARK: - Property
    
    var giveSentence: String {
        return "\(self.friendName)님께 \(self.holiday.addForSuffix()) \(self.item.addObjectSuffix()) 전달했습니다"
    }
    
    var takeSentence: String {
        return "\(self.friendName)님께서 \(self.holiday.addForSuffix()) \(self.item.addObjectSuffix()) 전달해주셨습니다"
    }
    
    // Dummy Data
    static let dummies: [History] = [
        History.init(id: 0, isTaken: true, holiday: "축의금", date: "20190103", item: "50000", friendId: 2),
        History.init(id: 1, isTaken: false, holiday: "생일선물", date: "20190108", item: "커피", friendId: 2),
        History.init(id: 2, isTaken: true, holiday: "생일선물", date: "20180926", item: "커피", friendId: 2),
        History.init(id: 3, isTaken: true, holiday: "어머니 장례", date: "20181125", item: "100000", friendId: 2),
        History.init(id: 4, isTaken: false, holiday: "축의금", date: "20181210", item: "50000", friendId: 2)]
}



