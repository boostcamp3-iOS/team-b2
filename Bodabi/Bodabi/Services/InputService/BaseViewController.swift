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
    var databaseManager: DatabaseManager! { get set }
}

extension Inputable where Self: UIViewController {
    mutating func setInputManager(_ manager: InputManager) {
        inputManager = manager
    }
    
    mutating func setDatabaseManager(_ manager: DatabaseManager) {
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

class MockHolidayInputViewController: UIViewController, HolidayType {
    var databaseManager: DatabaseManager!
    var inputManager: InputManager!
    
    var cellType: CellType = .relation
    var cellData: [String]?
    
    var isDeleting: Bool = false
    var selectedRelation: String?
    var selectedHoliday: String?
    
    var holidays: [Holiday]?
    
    var guideLabel: UILabel!
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputManager.inputType = .holiday
        fetchHoliday()
        fetchDefaultData()
    }
    
    func fetchHoliday() {
        databaseManager.fetch(type: Holiday.self) { result in
            switch result {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(holidays):
                self.holidays = holidays
            }
        }
    }
    
    func fetchDefaultData() {
        if let data = UserDefaults.standard.array(forKey: cellType.userDefaultKey) as? [String] {
            cellData = data
            tableView.reloadData()
        }
    }
    
    private func initTableView() {
        tableView.dataSource = self
    }
    
    private func initGuideLabel() {
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addHolidayAtHome:
            guideLabel.text = cellType.guideLabel
        case .addUpcomingEventAtHome,
             .addHistoryAtFriendHistory:
            guideLabel.text = "친구의 경조사는\n무엇입니까?"
        default:
            break
        }
        
        guideLabel.text = inputManager.entryType.guideLabel
    }
    
    private func initNavigationBar() {
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addHolidayAtHome:
            if cellType == .holiday {
                let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_backButton"), style: .plain, target: self, action: #selector(popCurrentInputView(_:)))
                backButton.tintColor = UIColor.mainColor
                navigationItem.leftBarButtonItem = backButton
            }
        case .addUpcomingEventAtHome:
            let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_backButton"), style: .plain, target: self, action: #selector(popCurrentInputView(_:)))
            backButton.tintColor = UIColor.mainColor
            navigationItem.leftBarButtonItem = backButton
        default:
            break
        }
        
        navigationController?.navigationBar.clear()
    }
}

extension MockHolidayInputViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellData?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(HolidayInputViewCell.self, for: indexPath)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        
        cell.holidaybutton.addTarget(self, action: #selector(touchUpHoildayButton(_:)), for: .touchUpInside)
        cell.deleteButton.addTarget(self, action: #selector(touchUpDeleteButton(_:)), for: .touchUpInside)
        
        if let cellData = cellData {
            cell.bind(cellData[indexPath.row])
        }
        
        if indexPath.row != 0 {
            cell.addGestureRecognizer(longPressRecognizer)
            cell.isDeleting = isDeleting
        }
        
        return cell
    }
}
