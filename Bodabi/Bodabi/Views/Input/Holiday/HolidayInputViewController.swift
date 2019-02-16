//
//  HolidayInputViewController.swift
//  Bodabi
//
//  Created by Kim DongHwan on 26/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class HolidayInputViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var guideLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Property
    
    private var databaseManager: DatabaseManager!
    public var inputData: InputData!
    public var entryRoute: EntryRoute!
    public var isRelationInput: Bool = true
    private var isDeleting: Bool = false
    public var myHolidays: [String]? {
        didSet {
            tableView.reloadData()
            UserDefaults.standard.set(myHolidays, forKey: "defaultHoliday")
        }
    }
    public var myRelations: [String]? {
        didSet {
            tableView.reloadData()
            UserDefaults.standard.set(myRelations, forKey: "defaultRelation")
        }
    }
    private var selectedHoliday: String?
    private var selectedRelation: String?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initDefaultData()
        initTableView()
        initGuideLabel()
        initNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setDeleteButton(to: false)
    }
    
    // MARK: - Initialization
    
    private func initDefaultData() {
        if isRelationInput {
            if let defaultRelation = UserDefaults.standard.array(forKey: "defaultRelation") as? [String] {
                myRelations = defaultRelation
            }
        } else {
            if let defaultHoliday = UserDefaults.standard.array(forKey: "defaultHoliday") as? [String] {
                myHolidays = defaultHoliday
            }
        }
    }
    
    private func initTableView() {
        tableView.delegate = self; tableView.dataSource = self
    }
    
    private func initGuideLabel() {
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addHolidayAtHome:
            if isRelationInput {
                guideLabel.text = "누구의 경조사를\n추가하시겠어요?"
            } else {
                guideLabel.text = "어떤 경조사를\n추가하시겠어요?"
            }
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
            if !isRelationInput {
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
    
    // MARK: - IBAction
    
    @IBAction func dismissInputView(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Objc
    
    @objc func touchUpHoildayButton(_ sender: UIButton) {
        if isRelationInput {
            selectedRelation = sender.titleLabel?.text
        } else {
            selectedHoliday = sender.titleLabel?.text
        }
        
        guard let entryRoute = entryRoute else { return }
        
        if selectedHoliday == "+" || selectedRelation == "+" {
            let viewController = storyboard(.input)
                .instantiateViewController(ofType: NameInputViewController.self)
            
            viewController.entryRoute = .addHolidayAtHome
            viewController.delegate = self
            viewController.isRelationInput = isRelationInput
            let navController = UINavigationController(rootViewController: viewController)
            present(navController, animated: true, completion: nil)
        } else {
            switch entryRoute {
            case .addHolidayAtHome:
                if isRelationInput {
                    let viewController = storyboard(.input)
                        .instantiateViewController(ofType: HolidayInputViewController.self)
                    
                    viewController.entryRoute = entryRoute
                    viewController.setDatabaseManager(databaseManager)
                    inputData?.relation = selectedRelation
                    viewController.inputData = inputData
                    viewController.isRelationInput = false
                    navigationController?.pushViewController(viewController, animated: true)
                } else {
                    let viewController = storyboard(.input)
                        .instantiateViewController(ofType: DateInputViewController.self)
                    
                    viewController.entryRoute = entryRoute
                    viewController.setDatabaseManager(databaseManager)
                    inputData?.holiday = selectedHoliday
                    viewController.inputData = inputData
                    navigationController?.pushViewController(viewController, animated: true)
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
            setDeleteButton(to: true)
            addTapGesture()
        }
    }
    
    @objc func touchUpDeleteButton(_ sender: UIButton) {
        guard let indexPath = tableView.indexPathForView(sender) else { return }
        if isRelationInput {
            myRelations?.remove(at: indexPath.row)
        } else {
            myHolidays?.remove(at: indexPath.row)
        }
    }
    
    @objc func popCurrentInputView(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension HolidayInputViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isRelationInput {
            return myRelations?.count ?? 1
        } else {
            return myHolidays?.count ?? 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(HolidayInputViewCell.self, for: indexPath)
        
        cell.holidaybutton.backgroundColor = indexPath.row == 0 ? UIColor.offColor : UIColor.starColor

        if let myHolidays = myHolidays {
            cell.holidaybutton.setTitle(myHolidays[indexPath.row], for: .normal)
        } else if let myRelations = myRelations {
            cell.holidaybutton.setTitle(myRelations[indexPath.row], for: .normal)
        }
        
        cell.holidaybutton.addTarget(self, action: #selector(touchUpHoildayButton(_:)), for: .touchUpInside)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        
        if indexPath.row != 0 {
            cell.addGestureRecognizer(longPressRecognizer)
            cell.isDeleting = isDeleting
        }
        
        cell.deleteButton.addTarget(self, action: #selector(touchUpDeleteButton(_:)), for: .touchUpInside)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HolidayInputViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) as? HolidayInputViewCell,
//            indexPath.row != 0 else { return }
//
//        cell.isDeleting = isDeleting
//    }
}

// MARK: - DatabaseManagerClient

extension HolidayInputViewController: DatabaseManagerClient {
    func setDatabaseManager(_ manager: DatabaseManager) {
        databaseManager = manager
    }
}
