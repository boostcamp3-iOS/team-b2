//
//  FriendHistoryViewController.swift
//  Bodabi
//
//  Created by jaehyeon lee on 25/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class FriendHistoryViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private var histories: [History] = [History]()

    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        histories = History.dummyHistories
        tableView.dataSource = self
        initNavigationBar()
        initTableView()
    }
    
    // MARK: - Initialization Methods
    
    private func initNavigationBar() {
        navigationController?.view.backgroundColor = .clear
    }
    
    private func initTableView() {
        let cells = [FriendHistoryReceiveViewCell.self, FriendHistorySendViewCell.self]
        tableView.register(cells)
    
    }
}

extension FriendHistoryViewController: UITableViewDataSource {
    
    // MARK: - TableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: FriendHistoryReceiveViewCell.reuseIdentifier, for: indexPath) as? FriendHistoryReceiveViewCell else {
//            return UITableViewCell()
//        }
//        return cell
        let item = histories[indexPath.row]
        switch item.isTaken {
        case true:
            if let cell = tableView.dequeueReusableCell(withIdentifier: FriendHistoryReceiveViewCell.reuseIdentifier, for: indexPath) as? FriendHistoryReceiveViewCell {
                cell.history = item
                return cell
            }
        case false:
            if let cell = tableView.dequeueReusableCell(withIdentifier: FriendHistorySendViewCell.reuseIdentifier, for: indexPath) as? FriendHistorySendViewCell {
                cell.history = item
                return cell
            }
        }
        return UITableViewCell()
    }
}
