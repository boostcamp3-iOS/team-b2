//
//  NotificationViewController.swift
//  Bodabi
//
//  Created by jaehyeon lee on 27/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private var notifications: [Notification]?
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notifications = Notification.dummyNotifications
        initTableView()
    }
    
    // MARK: - Initialization Methods
    
    private func initTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        let cell = NotificationViewCell.self
        tableView.register(cell)
        tableView.tableFooterView = UIView()
    }
}

// MARK: - TableView DataSource

extension NotificationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(NotificationViewCell.self, for: indexPath)
        
        guard let notification = notifications?[indexPath.row] else {
            return cell
        }
        
        cell.notification = notification
        return cell
    }
}

// MARK: - TableView Delegate

extension NotificationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = storyboard(.friendHistory)
            .instantiateViewController(ofType: FriendHistoryViewController.self)
        navigationController?.pushViewController(viewController, animated: true)
    }
}



