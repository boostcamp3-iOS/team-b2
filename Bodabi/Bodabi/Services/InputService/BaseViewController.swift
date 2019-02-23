//
//  InputViewController.swift
//  Bodabi
//
//  Created by Kim DongHwan on 20/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

// 각 인풋 타입에 따라 필요한 데이터들을 정의한 프로토콜
// 각 프로토콜을 확장하여 기본 데이터를 주입한다.
// 필요한 CoreData를 인풋에 맞게 fetch 해오는 메소드를 정의하자.

protocol Inputable {
    var inputManager: InputManager! { get set }
    var databaseManager: CoreDataManager! { get set }
}

extension Inputable where Self: UIViewController {
    mutating func setInputManager(_ manager: InputManager) {
        inputManager = manager
    }
    
    mutating func setDatabaseManager(_ manager: CoreDataManager) {
        databaseManager = manager
    }
}

protocol HolidayType: Inputable {
    var cellType: CellType { get set }
    var cellData: [String]? { get set }
    var isDeleting: Bool { get set }
    var selectedRelation: String? { get set }
    var selectedHoliday: String? { get set }
    var holidays: [Holiday]? { get set }
    
    func fetchHoliday()
    func fetchDefaultData()
}

protocol NameType {
    
}

protocol ItemType {
    
}

protocol DateType {
    
}

extension HolidayType where Self: UIViewController {
}

// Input을 하는 viewController들은 InputViewController를 상속받아,
// InputData와 EntryType을 가지고 Input 과정을 managing하는 InputManager를 주입받는다.
