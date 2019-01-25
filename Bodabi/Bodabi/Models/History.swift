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
    let date: String
    let item: String
    
    // TODO: - Replace property to 'friendID' after database loading
    let friendName: String
    
    // Dummy Data
    static let dummyHistories: [History] = [
        History.init(id: 0, isTaken: true, holiday: "결혼", date: "12.10", item: "50,000원", friendName: "김철수"),
        History.init(id: 1, isTaken: false, holiday: "생일", date: "1.12", item: "커피", friendName: "김철수"),
        History.init(id: 2, isTaken: true, holiday: "결혼", date: "1.16", item: "50,000", friendName: "김철수"),
        History.init(id: 3, isTaken: true, holiday: "결혼", date: "1.21", item: "50,000", friendName: "김철수"),
        History.init(id: 4, isTaken: false, holiday: "결혼", date: "1.22", item: "50,000", friendName: "김철수")]
}



