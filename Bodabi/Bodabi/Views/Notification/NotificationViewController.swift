//
//  NotificationViewController.swift
//  Bodabi
//
//  Created by jaehyeon lee on 27/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Propertie
    
    private var notifications: [Notification]?
    
    // MARK: - Lifecycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notifications = Notification.dummies
        initTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initNavigationBar()
    }
    
    // MARK: - Initialization
    
    private func initTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        let cell = NotificationViewCell.self
        tableView.register(cell)
        tableView.tableFooterView = UIView()
    }
    
    private func initNavigationBar(){
        navigationController?.navigationBar.clear()
    }
}

// MARK: - UITableViewDataSource

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

// MARK: - UITableViewDelegate

extension NotificationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = storyboard(.friendHistory)
            .instantiateViewController(ofType: FriendHistoryViewController.self)
        navigationController?.pushViewController(viewController, animated: true)
    }
}



