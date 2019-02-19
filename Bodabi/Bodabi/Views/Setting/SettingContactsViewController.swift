//
//  SettingContactsViewController.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 19..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Contacts
import UIKit

class SettingContactsViewController: UIViewController {
    
    // MARK: - IBOutlet

    @IBOutlet var tableView: UITableView!
    @IBOutlet var fetchSelectedContactsButton: UIButton!
    
    // MARK: - Property
    
    public var databaseManager: DatabaseManager!
    private var friends: [Friend]?
    private var contacts: [CNContact]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    struct Const {
        static let buttonInsetSize: CGFloat = 3.0
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initButton()
        initTableView()
        fetchFriend()
        fetchContacts()
    }
    
    // MARK: - IBAction
    
    @IBAction func touchUpFetchAllContactsButton(_ sender: UIButton) {
        contacts?.forEach { [weak self] (contact) in
            ContactManager.shared
                .convertAndSaveFriend(from: contact, database: databaseManager) { [weak self] (_) in
                    self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func touchUpFetchSelectedContactsButton(_ sender: Any) {
        let contacts = tableView.indexPathsForSelectedRows?.map { (indexPath) in
            return (tableView.cellForRow(at: indexPath) as? FriendViewCell)?.contact ?? CNContact()
        }
        contacts?.forEach { [weak self] (contact) in
            ContactManager.shared
                .convertAndSaveFriend(from: contact, database: databaseManager) { [weak self] (_) in
                    self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - Initialization
    
    private func initButton() {
        fetchSelectedContactsButton.imageView?.contentMode = .scaleAspectFit
        fetchSelectedContactsButton.imageEdgeInsets = UIEdgeInsets(top: Const.buttonInsetSize,
                                                                   left: -Const.buttonInsetSize,
                                                                   bottom: Const.buttonInsetSize,
                                                                   right: Const.buttonInsetSize)
    }
    
    private func initTableView() {
        tableView.delegate = self; tableView.dataSource = self
        
        tableView.register(FriendViewCell.self)
    }
    
    // MARK: - Method
    
    private func fetchFriend() {
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        databaseManager.fetch(type: Friend.self,
                              sortDescriptor: sortDescriptor) { [weak self] (result) in
                                self?.friends = result
                                self?.fetchContacts()
        }
    }
    
    private func fetchContacts() {
        ContactManager.shared
            .fetchNonexistentContact(existingFriends: friends) { [weak self] (contacts) in
                self?.contacts = contacts
        }
    }
    
}

// MARK: - UITableViewDelegate

extension SettingContactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = "\(tableView.indexPathsForSelectedRows?.count ?? 0)개 추가"
        fetchSelectedContactsButton.setTitle(title, for: .normal)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let title = "\(tableView.indexPathsForSelectedRows?.count ?? 0)개 추가"
        fetchSelectedContactsButton.setTitle(title, for: .normal)
    }
}

// MARK: - UITableViewDataSource

extension SettingContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(FriendViewCell.self, for: indexPath)
        cell.contact = contacts?[indexPath.row]
        return cell
    }
}
