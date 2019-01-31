//
//  HolidayInputViewController.swift
//  Bodabi
//
//  Created by Kim DongHwan on 26/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class HolidayInputViewController: UIViewController {
    
    // MARK: - @IBOutlets
    
    @IBOutlet weak var guideLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    public weak var delegate: HomeViewController?
    public var entryRoute: EntryRoute!
    public var myHolidaies = ["+", "결혼", "생일", "돌잔치", "장례", "출산"] {
        didSet {
            tableView.reloadData()
        }
    }
    private var selectedHoliday: String?
    
    // MARK: - Lifecycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        initGuideLabel()
        initNavigationBar()
    }
    
    // MARK: - Initialization Methods
    
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
    
    // MARK: - @IBAction Methods
    
    @IBAction func dismissInputView(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - @objc Methods
    
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
            case .addHolidayAtHome:
                dismiss(animated: true, completion: nil)
            case .addUpcomingEventAtHome:
                let viewController = storyboard(.input)
                    .instantiateViewController(ofType: DateInputViewController.self)
                
                viewController.entryRoute = entryRoute
                navigationController?.pushViewController(viewController, animated: true)
            case .addHistoryAtFriendHistory:
                let viewController = storyboard(.input)
                    .instantiateViewController(ofType: ItemInputViewController.self)
                
                viewController.entryRoute = entryRoute
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
        return myHolidaies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "holidayCellId", for: indexPath) as? HolidayInputViewCell else {
            return UITableViewCell()
        }
        
        cell.holidaybutton.setTitle(myHolidaies[indexPath.row], for: .normal)
        cell.holidaybutton.addTarget(self, action: #selector(touchUpHoildayButton(_:)), for: .touchUpInside)
        if indexPath.row == 0 {
            cell.holidaybutton.backgroundColor = UIColor.offColor
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HolidayInputViewController: UITableViewDelegate {
    
}
