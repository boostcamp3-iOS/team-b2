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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet var indexsVisibleConstraint: NSLayoutConstraint!
    
    // MARK: - Property
    
    private var databaseManager: DatabaseManager!
    private var friends: [Friend]?
    private var favoriteFriends: [Friend]?
    private let indexs: [Character] = ["★", "•", "ㄱ", "ㄴ", "ㄷ", "ㄹ", "ㅁ", "ㅂ",
                                       "ㅅ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ", "A"]
    private let lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    private var cellHeightSize: CGFloat = .init() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var searchFriends: [Friend]?
    private var searchFavoriteFriends: [Friend]?
    
    private var keyboardDismissGesture: UITapGestureRecognizer?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    struct Const {
        static let bottomInset: CGFloat = 90.0
        static let buttonAnimationScale: CGFloat = 1.3
        static let buttonAnimationDuration: TimeInterval = 0.18
        
        static let cellWidthSize: CGFloat = 30.0
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
        initCollectionView()
        initKeyboard()
        fetchFriend()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchFriend()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cellHeightSize = collectionView.bounds.size.height / CGFloat(indexs.count)
    }
    
    // MARK: - IBAction
    
    @IBAction func touchUpAddFriendButton(_ sender: UIButton) {
        let viewController = storyboard(.input)
            .instantiateViewController(ofType: NameInputViewController.self)
        viewController.isRelationInput = false
        viewController.entryRoute = .addFriendAtFriends
        viewController.setDatabaseManager(databaseManager)
        viewController.inputData = InputData()
        let navController = UINavigationController(rootViewController: viewController)
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func touchUpGoFetchContactsButton(_ sender: UIButton) {
        let viewController = storyboard(.setting)
            .instantiateViewController(ofType: SettingContactsViewController.self)
        viewController.setDatabaseManager(databaseManager)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Initialization
    
    private func initNavigationBar() {
        // navigation bar line clear
        // Please make 'isTranslucent' false in storyboard
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func initSearchBar() {
        searchBar.delegate = self
        
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
    }
    
    private func initTableView() {
        tableView.delegate = self; tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        
        let cells = [FriendsHeaderViewCell.self, FriendViewCell.self]
        tableView.register(cells)
        
        tableView.contentInset.bottom = Const.bottomInset
    }
    
    private func initCollectionView() {
        collectionView.delegate = self; collectionView.dataSource = self
        
        collectionView.register(FriendsIndexViewCell.self)
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
    
    private func setEmptyView(friends: [Friend]) {
        emptyView.isHidden = friends.count == 0 ? false : true
    }
    
    private func fetchFriend() {
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        databaseManager.fetch (
            type: Friend.self,
            sortDescriptor: sortDescriptor
        ) { [weak self] (result) in
            switch result {
            case let .failure(error):
                error.loadErrorAlert(title: "친구 불러오기 에러")
            case let .success(friends):
                self?.friends = friends
                self?.setEmptyView(friends: friends)
                self?.sortFriend()
                self?.tableView.reloadData()
                self?.searchBar.text = ""
            }
        }
    }
    
    private func sortFriend() {
        if let friends = friends?.sorted(by: { ($0.name ?? "") < ($1.name ?? "") }) {
            let hangulFriends = friends.filter {
                $0.name?.first?.isHangul ?? true || $0.name?.first?.isConsonant ?? true
            }
            let etcFriends = friends.filter {
                !($0.name?.first?.isHangul ?? true || $0.name?.first?.isConsonant ?? true)
            }
            self.friends = (hangulFriends + etcFriends)
        }
        
        favoriteFriends = friends?.filter { $0.favorite == true }
        friends = friends?.filter { $0.favorite == false }
        
        searchFriends = friends
        searchFavoriteFriends = favoriteFriends
    }
    
    private func reloadFriends(friends: [Friend]?,
                               favoriteFriends: [Friend]?,
                               completion: (() -> Void)? = nil) {
        searchFriends = friends
        searchFavoriteFriends = favoriteFriends
        tableView.reloadSections(IndexSet(integersIn: 1...3), with: .none)
        
        completion?()
    }
    
    private func isVisibleIndexCollection(_ visible: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.indexsVisibleConstraint.isActive = visible
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - @objcs
    
    @objc func touchUpFriendFavoriteButton(_ sender: UIButton) {
        guard sender.isSelected ?
            (sender.tag < favoriteFriends?.count ?? 0) : (sender.tag < friends?.count ?? 0) else { return }
        (sender.isSelected ? favoriteFriends?[sender.tag] : friends?[sender.tag])?
            .favorite = !sender.isSelected
        try? databaseManager?.viewContext.save()
        
        guard let friends = friends,
            let favoriteFriends = favoriteFriends else { return }
        self.friends = (friends + favoriteFriends)
        sortFriend()
        
        reloadFriends(friends: self.friends,
                      favoriteFriends: self.favoriteFriends)
        
        searchBar.text = ""
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
        keyboardDismissGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(tapBackground(_:))
        )
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
        
        let friend = section == .favorite ?
            searchFavoriteFriends?[indexPath.row] : searchFriends?[indexPath.row]
        
        viewController.friendID = friend?.objectID
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView (_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section),
            (section == .favorite || section == .friends) else { return }
        if editingStyle == .delete,
            let friend = section == .favorite ?
                searchFavoriteFriends?[indexPath.row] : searchFriends?[indexPath.row] {
            databaseManager?.viewContext.delete(friend)
        }
        do {
            try databaseManager?.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
        fetchFriend()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let section = Section(rawValue: indexPath.section),
            (section == .favorite || section == .friends) else { return false }
        return true
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
            return searchFavoriteFriends?.count ?? 0
        }
        return searchFriends?.count ?? 0
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
            
            guard let friends = section == .friends ?
                searchFriends : searchFavoriteFriends else { return cell }
            cell.friend = friends[indexPath.row]
            cell.setLastLine(line: indexPath.row == (friends.count - 1))
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate

extension FriendsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        lightImpactFeedbackGenerator.impactOccurred()
        
        if case Section.favoriteHeader.rawValue..<Section.friendsHeader.rawValue = indexPath.row {
            tableView.scrollToRow(at: IndexPath(row: 0, section: indexPath.row * 2),
                                  at: .top, animated: true)
        } else {
            guard let friends = searchFriends else { return }
            for (i, friend) in friends.enumerated()
                where (friend.name?.first ?? .init(""))
                    .contains(syllable: indexs[indexPath.row]) {
                        tableView.scrollToRow(
                            at: IndexPath(row: i,
                                          section: Section.friends.rawValue),
                            at: .top, animated: true
                        )
                        break
            }
        }
        
        let viewController = storyboard(.friends)
            .instantiateViewController(ofType: IndexAlertViewController.self)
        viewController.indexTitle = indexs[indexPath.row]
        present(viewController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource

extension FriendsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return indexs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(FriendsIndexViewCell.self, for: indexPath)
        cell.indexTitle = indexPath.row % 2 == 1 ?
            Character("•") : indexs[indexPath.row]
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FriendsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Const.cellWidthSize,
                      height: cellHeightSize)
    }
}

// MARK: - DatabaseManagerClient

extension FriendsViewController: DatabaseManagerClient {
    func setDatabaseManager(_ manager: DatabaseManager) {
        databaseManager = manager
    }
}

// MARK: - UISearchBarDelegate

extension FriendsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchBar.text,
            searchText != "" else {
                reloadFriends(
                    friends: self.friends,
                    favoriteFriends: self.favoriteFriends
                ) { [weak self] in
                    self?.isVisibleIndexCollection(true)
                }
                return
        }
        
        let friends = self.friends?.filter {
            ($0.name ?? "").contains(search: searchText)
        }
        let favoriteFriends = self.favoriteFriends?.filter {
            ($0.name ?? "").contains(search: searchText)
        }
        reloadFriends(
            friends: friends,
            favoriteFriends: favoriteFriends
        ) { [weak self] in
                self?.isVisibleIndexCollection(false)
        }
    }
}
