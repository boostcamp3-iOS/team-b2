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
    
    enum Section: Int, CaseIterable {
        case myHoliday
        case holidays
        case friendsHistory
        case histories
        
        public var title: String {
            switch self {
            case .myHoliday:
                return "나의 경조사"
            case .friendsHistory:
                return "다가오는 이벤트"
            default:
                return .init()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        initTableView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        getBackUI()
    }
    
    private func setUpUI() {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func getBackUI() {
        navigationController?.navigationBar.isHidden = false
    }

}

extension HomeViewController: UITableViewDelegate {
    private func initTableView() {
        tableView.delegate = self; tableView.dataSource = self
        
        tableView.register(HomeTitleViewCell.self)
        tableView.register(MyHolidaysViewCell.self)
        tableView.register(FriendsHistoriesViewCell.self)
    }
}

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section), section == .histories else {
            return 1
        }
        
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .myHoliday,
             .friendsHistory:
            let cell = tableView.dequeue(HomeTitleViewCell.self, for: indexPath)
            cell.type = section
            return cell
            
        case .holidays:
            let cell = tableView.dequeue(MyHolidaysViewCell.self, for: indexPath)
            return cell
        case .histories:
            let cell = tableView.dequeue(FriendsHistoriesViewCell.self, for: indexPath)
            return cell
        }
    }
}
