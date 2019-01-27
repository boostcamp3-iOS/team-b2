//
//  HomeViewController.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 25..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var addedHoliday: String? {
        didSet {
            print(addedHoliday ?? "")
        }
    }
    
    enum Section: Int, CaseIterable {
        case myHoliday
        case holidays
        case upcomingEvent
        case friendEvents
        
        public var title: String {
            switch self {
            case .myHoliday:
                return "나의 경조사"
            case .upcomingEvent:
                return "다가오는 이벤트"
            default:
                return .init()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        getBackUI()
    }
    
    private func initNavigationBar() {
        navigationController?.navigationBar.clear()
    }
    
    private func setUpUI() {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func getBackUI() {
        navigationController?.navigationBar.isHidden = false
    }
    
    @objc func touchUpAddHolidaybutton(_ sender: UIButton) {
        let viewController = storyboard(.input)
            .instantiateViewController(ofType: HolidayInputViewController.self)
        let navController = UINavigationController(rootViewController: viewController)
        
        viewController.delegate = self
        viewController.entryRoute = .addHolidayAtHome
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc func touchUpAddUpcomingDatebutton(_ sender: UIButton) {
        let viewController = storyboard(.input)
            .instantiateViewController(ofType: NameInputViewController.self)
        let navController = UINavigationController(rootViewController: viewController)
        
        viewController.delegate = self
        viewController.entryRoute = .addUpcomingEventAtHome
        self.present(navController, animated: true, completion: nil)
    }
}

extension HomeViewController: UITableViewDelegate {
    private func initTableView() {
        tableView.delegate = self; tableView.dataSource = self
        
        let cells = [HomeTitleViewCell.self, MyHolidaysViewCell.self, UpcomingEventViewCell.self]
        tableView.register(cells)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        switch section {
        case .friendEvents:
            let viewController = storyboard(.friendHistory)
                .instantiateViewController(ofType: FriendHistoryViewController.self)
            navigationController?.pushViewController(viewController, animated: true)
        default:
            break
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section), section == .friendEvents else {
            return 1
        }
        
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .myHoliday:
            let cell = tableView.dequeue(HomeTitleViewCell.self, for: indexPath)
            cell.addHolidayButton.addTarget(self, action: #selector(touchUpAddHolidaybutton(_:)), for: .touchUpInside)
            cell.type = section
            return cell
        case .upcomingEvent:
            let cell = tableView.dequeue(HomeTitleViewCell.self, for: indexPath)
            cell.addHolidayButton.addTarget(self, action: #selector(touchUpAddUpcomingDatebutton(_:)), for: .touchUpInside)
            cell.type = section
            return cell
        case .holidays:
            let cell = tableView.dequeue(MyHolidaysViewCell.self, for: indexPath)
            return cell
        case .friendEvents:
            let cell = tableView.dequeue(UpcomingEventViewCell.self, for: indexPath)
            return cell
        }
    }
}
