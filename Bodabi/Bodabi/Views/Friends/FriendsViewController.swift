//
//  FriendsViewController.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 27..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import CoreData
import UIKit

class FriendsViewController: UIViewController {
    
    // MARK: - IBOutlet

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Property
    
    private var databaseManager: DatabaseManager!
    private var friends: [Friend]?
    private var favoriteFriends: [Friend]?
    
    private var keyboardDismissGesture: UITapGestureRecognizer?
    
    struct Const {
        static let bottomInset: CGFloat = 90.0
        static let buttonAnimationScale: CGFloat = 1.3
        static let buttonAnimationDuration: TimeInterval = 0.18
    }
    
    enum Section: Int, CaseIterable {
        case favoriteHeader
        case favorite
        case friendsHeader
        case friends
        
        var title: String {
            switch self {
            case .favoriteHeader:
                return "즐겨찾기"
            case .friendsHeader:
                return "친구 목록"
            default:
                return .init()
            }
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initNavigationBar()
        initSearchBar()
        initTableView()
        initKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchFriend()
    }
    
    // MARK: - IBAction
    
    @IBAction func touchUpAddFriendButton(_ sender: UIButton) {
        let viewController = storyboard(.input)
            .instantiateViewController(ofType: NameInputViewController.self)
        viewController.entryRoute = .addFriendAtFriends
        viewController.setDatabaseManager(databaseManager)
        viewController.inputData = InputData()
        let navController = UINavigationController(rootViewController: viewController)
        self.present(navController, animated: true, completion: nil)
    }
    
    // MARK: - Initialization
    
    private func initNavigationBar() {
        // navigation bar line clear
        // Please make 'isTranslucent' false in storyboard
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func initSearchBar() {
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
    }
    
    private func initTableView() {
        tableView.delegate = self; tableView.dataSource = self
        
        let cells = [FriendsHeaderViewCell.self, FriendViewCell.self]
        tableView.register(cells)
        
        tableView.contentInset.bottom = Const.bottomInset
    }
    
    private func initKeyboard() {
        NotificationCenter.default
            .addObserver(self, selector: #selector(keyboardWillShow(_:)),
                         name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default
            .addObserver(self, selector: #selector(keyboardWillHide(_:)),
                         name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Method
    
    private func fetchFriend() {
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        if let result = try? databaseManager.viewContext.fetch(request) {
            friends = result.filter { $0.favorite == false }
            favoriteFriends = result.filter { $0.favorite == true }
            tableView.reloadData()
        }
    }
    
    // MARK: - @objcs
    
    @objc func touchUpFriendFavoriteButton(_ sender: UIButton) {
//        sender.setScaleAnimation(scale: Const.buttonAnimationScale,
//                                 duration: Const.buttonAnimationDuration)
        (sender.isSelected ? favoriteFriends?[sender.tag] : friends?[sender.tag])?.favorite = !sender.isSelected
        try? databaseManager?.viewContext.save()
        
        guard let friends = friends,
            let favoriteFriends = favoriteFriends else { return }
        let allFriends = (friends + favoriteFriends).sorted { $0.name ?? "" < $1.name ?? "" }
        self.friends = allFriends.filter { $0.favorite == false }
        self.favoriteFriends = allFriends.filter { $0.favorite == true }
        tableView.reloadSections(IndexSet(integersIn: 1...3), with: .fade)
    }
}

// MARK: - Keyboard will change

extension FriendsViewController {
    private func adjustKeyboardDismisTapGesture(isKeyboardVisible: Bool) {
        guard isKeyboardVisible else {
            guard let gesture = keyboardDismissGesture else { return }
            view.removeGestureRecognizer(gesture)
            keyboardDismissGesture = nil
            return
        }
        keyboardDismissGesture = UITapGestureRecognizer(target: self, action: #selector(tapBackground(_:)))
        guard let gesture = keyboardDismissGesture else { return }
        view.addGestureRecognizer(gesture)
    }
    
    @objc func tapBackground(_ sender: UITapGestureRecognizer?) {
        searchBar.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(_ notification: Foundation.Notification) {
        adjustKeyboardDismisTapGesture(isKeyboardVisible: true)
    }
    
    @objc func keyboardWillHide(_ notification: Foundation.Notification) {
        adjustKeyboardDismisTapGesture(isKeyboardVisible: false)
    }
    
}

// MARK: - UITableViewDelegate

extension FriendsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section),
            (section == .favorite || section == .friends) else { return }
        let viewController = storyboard(.friendHistory)
            .instantiateViewController(ofType: FriendHistoryViewController.self)
        viewController.setDatabaseManager(databaseManager)
        
        let friend = section == .favorite ? favoriteFriends?[indexPath.row] : friends?[indexPath.row]
        
        viewController.friend = friend
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension FriendsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section),
            (section == .favorite || section == .friends) else { return 1 }
        if section == .favorite {
            return favoriteFriends?.count ?? 0
        }
        return friends?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        switch section {
        case .favoriteHeader,
             .friendsHeader:
            let cell = tableView.dequeue(FriendsHeaderViewCell.self, for: indexPath)
            cell.type = section
            return cell
        case .favorite,
             .friends:
            let cell = tableView.dequeue(FriendViewCell.self, for: indexPath)
            cell.favoriteButton.tag = indexPath.row
            cell.favoriteButton
                .addTarget(self, action: #selector(touchUpFriendFavoriteButton(_:)),
                           for: .touchUpInside)
            
            guard let friends = section == .friends ? friends : favoriteFriends else { return cell }
            cell.friend = friends[indexPath.row]
            cell.setLastLine(line: indexPath.row == (friends.count - 1))
            return cell
        }
    }
}

// MARK: - DatabaseManagerClient

extension FriendsViewController: DatabaseManagerClient {
    func setDatabaseManager(_ manager: DatabaseManager) {
        databaseManager = manager
    }
}
