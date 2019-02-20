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
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        guard (contacts?.count ?? 0) > 0 else { return }
        saveContacts(contacts: contacts)
    }
    
    @IBAction func touchUpFetchSelectedContactsButton(_ sender: Any) {
        let contacts = tableView.indexPathsForSelectedRows?
            .map { (indexPath) in
                return (tableView.cellForRow(at: indexPath) as? FriendViewCell)?
                    .contact ?? CNContact()
        }
        guard (contacts?.count ?? 0) > 0 else { return }
        saveContacts(contacts: contacts)
    }
    
    // MARK: - Initialization
    
    private func initButton() {
        fetchSelectedContactsButton.imageView?.contentMode = .scaleAspectFit
        fetchSelectedContactsButton
            .imageEdgeInsets = UIEdgeInsets(
                top: Const.buttonInsetSize,
                left: -Const.buttonInsetSize,
                bottom: Const.buttonInsetSize,
                right: Const.buttonInsetSize
        )
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
                                switch result {
                                case let .failure(error):
                                    print(error.localizedDescription)
                                case let .success(friends):
                                    self?.friends = friends
                                    self?.fetchContacts()
                                }
        }
    }
    
    private func fetchContacts() {
        ContactManager.shared
            .fetchNonexistentContact(existingFriends: friends) { [weak self] (contacts) in
                self?.contacts = contacts
        }
    }
    
    private func saveContacts(contacts: [CNContact]?) {
        let alert = BodabiAlertController(
            title: "연락처 가져오기",
            message: "총 \(contacts?.count ?? 0)개의 연락처를 가져오시겠습니까?",
            type: nil,
            style: .Alert
        )
        
        // MARK: Fix me
        alert.cancelButtonTitle = "취소"
        alert.addButton(title: "확인") { [weak self] in
            contacts?.forEach { [weak self] (contact) in
                guard let databaseManager = self?.databaseManager else { return }
                ContactManager.shared.convertAndSaveFriend(
                    from: contact,
                    database: databaseManager
                ) { [weak self] (result) in
                    switch result {
                    case let .failure(error):
                        print(error.localizedDescription)
                    case .success:
                        self?.tabBarController?.selectedIndex = 1
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
        alert.show()
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