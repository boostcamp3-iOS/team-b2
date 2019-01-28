//
//  SettingViewController.swift
//  Bodabi
//
//  Created by jaehyeon lee on 27/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        initTableView()
        initDummyUserDefaults()
    }
    
    // MARK: - Initialization Methods
    
    private func initTableView() {
        let cell = SettingViewCell.self
        tableView.register(cell)
        tableView.tableFooterView = UIView()
    }
    
    private func initDummyUserDefaults() {
        UserDefaults.standard.set(50,forKey: "UserFontSize")
    }
}

// MARK: - TableView DataSource

extension SettingViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingOptions.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(SettingViewCell.self, for: indexPath)
        
        guard let setting = SettingOptions(rawValue: indexPath.row) else {
            return cell
        }
        
        cell.setting = setting
        return cell
    }
}
