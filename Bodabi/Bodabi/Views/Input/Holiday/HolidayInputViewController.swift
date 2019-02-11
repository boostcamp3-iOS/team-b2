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
    
    public var inputData: InputData?
    public var entryRoute: EntryRoute!
    public var myHolidaies: [String]? {
        didSet {
            tableView.reloadData()
            UserDefaults.standard.set(myHolidaies, forKey: "defaultHoliday")
        }
    }
    
    private var selectedHoliday: String?
    private var databaseManager: DatabaseManager!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        initGuideLabel()
        initNavigationBar()
        
        if let defaultHoliday = UserDefaults.standard.array(forKey: "defaultHoliday") as? [String] {
            myHolidaies = defaultHoliday
        }
    }
    
    // MARK: - Initialization
    
    private func initTableView() {
        tableView.delegate = self; tableView.dataSource = self
    }
    
    private func initGuideLabel() {
        guard let entryRoute = entryRoute else { return }
        
        switch entryRoute {
        case .addHolidayAtHome:
            guideLabel.text = "어떤 경조사를\n추가하시겠어요?"
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
        case .addUpcomingEventAtHome:
            let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_backButton"), style: .plain, target: self, action: #selector(popCurrentInputView(_:)))
            backButton.tintColor = UIColor.mainColor
            navigationItem.leftBarButtonItem = backButton
        default:
            break
        }
        
        navigationController?.navigationBar.clear()
    }
    
    // MARK: - IBAction
    
    @IBAction func dismissInputView(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Objc
    
    @objc func touchUpHoildayButton(_ sender: UIButton) {
        selectedHoliday = sender.titleLabel?.text

        guard let entryRoute = entryRoute else { return }
        
        if selectedHoliday == "+" {
            let viewController = storyboard(.input)
                .instantiateViewController(ofType: NameInputViewController.self)
            
            viewController.entryRoute = .addHolidayAtHome
            viewController.delegate = self
            let navController = UINavigationController(rootViewController: viewController)
            present(navController, animated: true, completion: nil)
        } else {
            switch entryRoute {
            case .addHolidayAtHome,
                 .addUpcomingEventAtHome:
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
    
    @objc func popCurrentInputView(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension HolidayInputViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myHolidaies?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(HolidayInputViewCell.self, for: indexPath)
        
        cell.holidaybutton.backgroundColor = indexPath.row == 0 ? UIColor.offColor : UIColor.starColor

        if let myHolidaies = myHolidaies {
            cell.holidaybutton.setTitle(myHolidaies[indexPath.row], for: .normal)
        } else {
            cell.holidaybutton.setTitle("+", for: .normal)
        }
        
        cell.holidaybutton.addTarget(self, action: #selector(touchUpHoildayButton(_:)), for: .touchUpInside)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HolidayInputViewController: UITableViewDelegate {
    
}

// MARK: -
extension HolidayInputViewController: DatabaseManagerClient {
    func setDatabaseManager(_ manager: DatabaseManager) {
        databaseManager = manager
    }
}
