//
//  HolidayInputViewController.swift
//  Bodabi
//
//  Created by Kim DongHwan on 26/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit
import CoreData

class HolidayInputViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var guideLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Property

    public var inputData: InputData!
    public var entryRoute: EntryRoute!
    public var cellType: CellType = .relation
    public var cellData: [String]?
    
    public var myHolidays: [String]? {
        didSet {
            tableView.reloadData()
            UserDefaults.standard.set(myHolidays, forKey: DefaultsKey.defaultHoliday)
        }
    }
    public var myRelations: [String]? {
        didSet {
            tableView.reloadData()
            UserDefaults.standard.set(myRelations, forKey: DefaultsKey.defaultRelation)
        }
    }
    private var databaseManager: CoreDataManager!
    private var isDeleting: Bool = false
    private var selectedRelation: String?
    private var selectedHoliday: String?
    private var holidays: [Holiday]?
    private let heavyImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        initGuideLabel()
        initNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchHoliday()
        fetchDefaultData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setDeleteButton(to: false)
    }
    
    // MARK: - Initialization
    
    private func fetchHoliday() {
        databaseManager.fetch(type: Holiday.self) { result in
            switch result {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(holidays):
                self.holidays = holidays
            }
        }
    }
    
    private func fetchDefaultData() {
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
    
    private func addTapGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapBackground(_:)))
        view.addGestureRecognizer(gesture)
    }
    
    private func setDeleteButton(to state: Bool) {
        let indexPaths = tableView.getAllIndexPathsInSection(section: 0)
        
        indexPaths.forEach {
            if $0.row != 0, let cell = tableView.cellForRow(at: $0) as? HolidayInputViewCell {
                cell.isDeleting = state
            }
        }
        
        isDeleting = state
    }
    
    private func isUniqueName() -> Bool {
        guard let holiday = selectedHoliday, let relation = selectedRelation else { return false }
        
        var isUnique: Bool = true
        let currentName: String = relation + "의 " + holiday
        
        holidays?.forEach {
            if $0.title == currentName {
                isUnique = false
            }
        }
        
        return isUnique
    }
    
    // MARK: - IBAction
    
    @IBAction func dismissInputView(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Objc
    
    @objc func touchUpHoildayButton(_ sender: UIButton) {
        switch cellType {
        case .relation:
            selectedRelation = sender.titleLabel?.text
        case .holiday:
            selectedHoliday = sender.titleLabel?.text
        }
        
        guard let entryRoute = entryRoute else { return }
        
        if selectedHoliday == "+" || selectedRelation == "+" {
            let viewController = storyboard(.input)
                .instantiateViewController(ofType: NameInputViewController.self)
            
            viewController.entryRoute = .addHolidayAtHome
            viewController.inputData = InputData()
            viewController.cellType = cellType
            let navController = UINavigationController(rootViewController: viewController)
            present(navController, animated: true, completion: nil)
        } else {
            switch entryRoute {
            case .addHolidayAtHome:
                switch cellType {
                case .relation:
                    let viewController = storyboard(.input)
                        .instantiateViewController(ofType: HolidayInputViewController.self)
                    
                    inputData?.relation = selectedRelation
                    
                    viewController.entryRoute = entryRoute
                    viewController.setDatabaseManager(databaseManager)
                    viewController.selectedRelation = selectedRelation
                    viewController.inputData = inputData
                    viewController.cellType = .holiday
                    navigationController?.pushViewController(viewController, animated: true)
                case .holiday:
                    if isUniqueName() {
                        let viewController = storyboard(.input)
                            .instantiateViewController(ofType: DateInputViewController.self)
                        
                        viewController.entryRoute = entryRoute
                        viewController.setDatabaseManager(databaseManager)
                        inputData?.holiday = selectedHoliday
                        viewController.inputData = inputData
                        navigationController?.pushViewController(viewController, animated: true)
                    } else {
                        let alert = BodabiAlertController(title: "주의", message: "중복된 이름입니다. 이름을 다시 입력해주세요.", type: nil, style: .Alert)
                        
                        alert.cancelButtonTitle = "확인"
                        alert.show()
                    }
                }
            case .addUpcomingEventAtHome:
                let viewController = storyboard(.input)
                    .instantiateViewController(ofType: DateInputViewController.self)
                
                viewController.entryRoute = entryRoute
                inputData?.holiday = selectedHoliday
                viewController.inputData = inputData
                viewController.setDatabaseManager(databaseManager)
                navigationController?.pushViewController(viewController, animated: true)
            case .addHistoryAtFriendHistory:
                let viewController = storyboard(.input)
                    .instantiateViewController(ofType: ItemInputViewController.self)
                
                viewController.entryRoute = entryRoute
                inputData?.holiday = selectedHoliday
                viewController.inputData = inputData
                viewController.setDatabaseManager(databaseManager)
                navigationController?.pushViewController(viewController, animated: true)
            default:
                break
            }
        }
    }
    
    @objc func tapBackground(_ sender: UITapGestureRecognizer) {
        guard let gesture = view.gestureRecognizers?.first else { return }
        view.removeGestureRecognizer(gesture)
        setDeleteButton(to: false)
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            heavyImpactFeedbackGenerator.impactOccurred()
            setDeleteButton(to: true)
            addTapGesture()
        }
    }
    
    @objc func touchUpDeleteButton(_ sender: UIButton) {
        guard let indexPath = tableView.indexPathForView(sender) else { return }
        
        cellData?.remove(at: indexPath.row)
    }
    
    @objc func popCurrentInputView(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension HolidayInputViewController: UITableViewDataSource {
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

// MARK: - DatabaseManagerClient

extension HolidayInputViewController: CoreDataManagerClient {
    func setDatabaseManager(_ manager: CoreDataManager) {
        databaseManager = manager
    }
}

// MARK: - Cell Protocol

protocol HolidayInputViewCellProtocol {
    func bind(_ data: String)
}
