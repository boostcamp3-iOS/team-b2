//
//  HolidayViewController.swift
//  Bodabi
//
//  Created by Kim DongHwan on 28/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class HolidayViewController: UIViewController {
    
    // MARK: - Type
    
    struct ThankFriend {
        var name: String
        var item: String
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var floatingButton: UIButton!
    
    // MARK: - Properties
    
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
    
    public var entryRoute: EntryRoute!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initNavigationBar()
        initTableView()
    }
    
    // MARK: - Initialization Methods
    
    private func initNavigationBar() {
        navigationController?.view.backgroundColor = .clear
    }
    
    @IBAction func touchUpFloatingButotn(_ sender: UIButton) {
        let viewController = storyboard(.input)
            .instantiateViewController(ofType: HolidayInputViewController.self)
        let navController = UINavigationController(rootViewController: viewController)
        
        viewController.entryRoute = .addHistoryAtFriendHistory
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc func popCurrentInputView(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension HolidayViewController: UITableViewDelegate {
    private func initTableView() {
        tableView.delegate = self; tableView.dataSource = self
        tableView.register(ThanksFriendViewCell.self)
    }
}

extension HolidayViewController: UITableViewDataSource {
    
    // MARK: - TableViewDataSource Methods
    
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
