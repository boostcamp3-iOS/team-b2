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
    
    public var inputData: InputData?
    public var entryRoute: EntryRoute!
//    public var myHolidaies = ["+", "결혼", "생일", "돌잔치", "장례", "출산"] {
//        didSet {
//            tableView.reloadData()
//        }
//    }
    private var myHolidaies: [Holiday]?
    private var selectedHoliday: String?
    private var databaseManager: DatabaseManager!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        initGuideLabel()
        initNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchHoliday()
    }
    
    private func fetchHoliday() {
        let request: NSFetchRequest<Holiday> = Holiday.fetchRequest()
        
        do {
            if let result: [Holiday] = try databaseManager?.viewContext.fetch(request) {
                myHolidaies = result
            }
        } catch {
            print(error.localizedDescription)
        }
        
        tableView.reloadData()
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
    
    // MARK: - objc
    
    @objc func touchUpHoildayButton(_ sender: UIButton) {
        selectedHoliday = sender.titleLabel?.text

        guard let entryRoute = entryRoute else { return }
        
        if selectedHoliday == "+" {
            let viewController = storyboard(.input)
                .instantiateViewController(ofType: NameInputViewController.self)
            
            viewController.addHolidayDelegate = self
            viewController.entryRoute = .addHolidayAtHome
            
            let navController = UINavigationController(rootViewController: viewController)
            present(navController, animated: true, completion: nil)
        } else {
            switch entryRoute {
            case .addHolidayAtHome,
                 .addUpcomingEventAtHome:
                let viewController = storyboard(.input)
                    .instantiateViewController(ofType: DateInputViewController.self)
                
                viewController.entryRoute = entryRoute
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
        guard let myHolidaies = myHolidaies else {
            return 1
        }
        return 1 + myHolidaies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(HolidayInputViewCell.self, for: indexPath)
        
        if indexPath.row == 0 {
            cell.holidaybutton.backgroundColor = UIColor.offColor
            cell.holidaybutton.setTitle("+", for: .normal)
        } else {
            cell.holidaybutton.setTitle(myHolidaies?[indexPath.row - 1].title, for: .normal)
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
