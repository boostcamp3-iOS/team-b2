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
    private let mediumImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
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
        fetchFriendAndFetchContact()
    }
    
    // MARK: - IBAction
    
    @IBAction func touchUpFetchAllContactsButton(_ sender: UIButton) {
        mediumImpactFeedbackGenerator.impactOccurred()
        guard (contacts?.count ?? 0) > 0 else { return }
        saveContactsAlert(contacts: contacts)
    }
    
    @IBAction func touchUpFetchSelectedContactsButton(_ sender: Any) {
        mediumImpactFeedbackGenerator.impactOccurred()
        let contacts = tableView.indexPathsForSelectedRows?
            .map { (indexPath) in
                return (tableView.cellForRow(at: indexPath) as? FriendViewCell)?
                    .contact ?? CNContact()
        }
        guard (contacts?.count ?? 0) > 0 else { return }
        saveContactsAlert(contacts: contacts)
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
    
    private func fetchFriendAndFetchContact() {
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        databaseManager.fetch(
            type: Friend.self,
            sortDescriptor: sortDescriptor
        ) { [weak self] (result) in
            switch result {
            case let .success(friends):
                self?.fetchContacts(friends: friends)
            case let .failure(error):
                error.loadErrorAlert(title: "친구목록 가져오기 에러")
            }
        }
    }
    
    private func fetchContacts(friends: [Friend]) {
        ContactManager.shared
            .fetchNonexistentContact(existingFriends: friends) { [weak self] (result) in
                switch result {
                case .success(let contacts):
                    self?.contacts = contacts
                case .failure(let err):
                    err.loadErrorAlert(alertHandler: { [weak self] (alert) in
                        alert.addButton(title: "설정으로 가기") { [weak self] in
                            self?.goSettingView()
                        }
                    })
                }
        }
    }
    
    private func saveContactsAlert(contacts: [CNContact]?) {
        let alert = BodabiAlertController(
            title: "연락처 가져오기",
            message: "총 \(contacts?.count ?? 0)개의 연락처를 가져오시겠습니까?",
            type: nil,
            style: .Alert
        )
        
        alert.cancelButtonTitle = "취소"
        alert.addButton(title: "확인") { [weak self] in
            self?.saveContacts(contacts: contacts)
        }
        alert.show()
    }
    
    private func goSettingView() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    private func saveContacts(contacts: [CNContact]?) {
        contacts?.enumerated().forEach { [weak self] (index, contact) in
            guard let databaseManager = self?.databaseManager else { return }
            ContactManager.shared.convertAndSaveFriend(
                from: contact,
                database: databaseManager
            ) { [weak self] (result) in
                switch result {
                case .success:
                    guard index == (contacts?.count ?? 0) - 1 else { return }
                    self?.tabBarController?.selectedIndex = TabBar.friends.rawValue
                    self?.navigationController?.popViewController(animated: true)
                case let .failure(error):
                    error.loadErrorAlert()
                }
            }
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

extension SettingContactsViewController: DatabaseManagerClient {
    func setDatabaseManager(_ manager: DatabaseManager) {
        databaseManager = manager
    }
}
