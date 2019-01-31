//
//  HolidayViewController.swift
//  Bodabi
//
//  Created by Kim DongHwan on 28/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class HolidayViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var floatingButton: UIButton!
    
    // MARK: - Properties
    
    public var entryRoute: EntryRoute!
    private var thanksFriendList: [ThankFriend] = [
        ThankFriend(name: "김철수", item: "50,000"),
        ThankFriend(name: "박영희", item: "30,000"),
        ThankFriend(name: "문재인", item: "500,000"),
        ThankFriend(name: "성시경", item: "50,000"),
        ThankFriend(name: "김미영", item: "전자레인지"),
        ThankFriend(name: "박영민", item: "100,000"),
        ThankFriend(name: "엄마", item: "냉장고"),
        ThankFriend(name: "고민준", item: "TV"),
        ThankFriend(name: "김철수", item: "50,000"),
        ThankFriend(name: "김철수", item: "50,000"),
        ThankFriend(name: "김철수", item: "50,000"),
        ThankFriend(name: "김철수", item: "50,000"),
        ThankFriend(name: "김철수", item: "50,000")]
    
    // MARK: - Lifecycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initTableView()
        initNavigationBar()
    }
    
    // MARK: - Initialization Methods
    
    private func initTableView() {
        tableView.delegate = self; tableView.dataSource = self
        tableView.register(ThanksFriendViewCell.self)
    }
    
    private func initNavigationBar() {
        navigationController?.view.backgroundColor = .clear
    }
    
    // MARK: - @IBAction
    
    @IBAction func touchUpFloatingButotn(_ sender: UIButton) {
        let viewController = storyboard(.input)
            .instantiateViewController(ofType: HolidayInputViewController.self)
        let navController = UINavigationController(rootViewController: viewController)
        
        viewController.entryRoute = .addHistoryAtFriendHistory
        present(navController, animated: true, completion: nil)
    }
    
    // MARK: - @objc
    
    @objc func popCurrentInputView(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension HolidayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thanksFriendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ThanksFriendViewCell.self, for: indexPath)
        let friend = thanksFriendList[indexPath.row]
        
        cell.itemLabel.text = friend.item
        cell.nameLabel.text = friend.name
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HolidayViewController: UITableViewDelegate {
    
}

// MARK: - Type

extension HolidayViewController {
    struct ThankFriend {
        var name: String
        var item: String
    }
}
