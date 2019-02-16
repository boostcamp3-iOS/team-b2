//
//  SettingViewController.swift
//  Bodabi
//
//  Created by jaehyeon lee on 27/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self; tableView.delegate = self
        initTableView()
        initDummyUserDefaults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initNavigationBar()
    }
    
    // MARK: - Initialization
    
    private func initTableView() {
        let cell = SettingViewCell.self
        tableView.register(cell)
        tableView.tableFooterView = UIView()
    }
    
    private func initNavigationBar(){
        //navigationController?.navigationBar.clear()
    }
    
    private func initDummyUserDefaults() {
        UserDefaults.standard.set(50,forKey: "UserFontSize")
    }
}

// MARK: - UITableViewDataSource

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

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let setting = SettingOptions(rawValue: indexPath.row) else {
            return
        }
        switch setting {
        case .question:
            let email = "knca2@naver.com"
            if let url = URL(string: "mailto:\(email)") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        case .facebook:
            let app = "fb://profile/548962302252309"
            let web = "https://www.facebook.com/548962302252309"
            let application = UIApplication.shared
            if application.canOpenURL(URL(string: app)!) {
                application.open(URL(string: app)!, options: [:], completionHandler: nil)
                application.open(URL(string: web)!, options: [:], completionHandler: nil)
            } else {
                application.open(URL(string: web)!, options: [:], completionHandler: nil)
            }
        case .notification:
            let viewController = storyboard(.setting)
                .instantiateViewController(ofType: SettingAlarmViewController.self)
            navigationController?.pushViewController(viewController, animated: true)
        default:
            break
        }
    }
}
