//
//  Tag.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 14..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

enum TagType: Int, CaseIterable {
    case contact
    case group
    case description
    
    var color: UIColor {
        switch self {
        case .contact:
            return #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        case .group:
            return #colorLiteral(red: 0.9254901961, green: 0.4274509804, blue: 0.3019607843, alpha: 1)
        case .description:
            return #colorLiteral(red: 0.9254901961, green: 0.3019607843, blue: 0.5409803922, alpha: 1)
        }
    }
    
    var title: String {
        switch self {
        case .contact:
            return "연락처"
        case .group:
            return "소속"
        case .description:
            return "수식어"
        }
    }
}

struct Tag: Hashable {
    let type: TagType
    let title: String
    
    public static var items: [Tag] {
        let items = [ Tag(type: .group, title: "회사"),
                     Tag(type: .group, title: "학교"),
                     Tag(type: .group, title: "가족"),
                     Tag(type: .group, title: "친척"),
                     Tag(type: .group, title: "동아리"),
                     Tag(type: .group, title: "교회"),
                     Tag(type: .group, title: "동네 친구"),
                     Tag(type: .description, title: "키가 큰"),
                     Tag(type: .description, title: "키가 작은"),
                     Tag(type: .description, title: "안경 쓴"),
                     Tag(type: .description, title: "덧니"),
                     Tag(type: .description, title: "여자"),
                     Tag(type: .description, title: "남자"),
                     Tag(type: .description, title: "수다스러운"),
                     Tag(type: .description, title: "조용한")]
        return items
    }
}
