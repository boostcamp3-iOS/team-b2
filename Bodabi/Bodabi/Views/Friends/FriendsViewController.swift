//
//  FriendsViewController.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 27..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    struct Const {
        static let bottomInset: CGFloat = 90.0
    }
    
    var friends: [Friend] = Friend.dummies {
        didSet {
            tableView.reloadData()
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        initTableView()
    }
    
    private func setUpUI() {
        // navigation bar line clear
        // Please make 'isTranslucent' false in storyboard
        navigationController?.navigationBar.shadowImage = UIImage()
        
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
    }
    
    @IBAction func touchUpAddFriendButton(_ sender: UIButton) {
        let viewController = storyboard(.input)
            .instantiateViewController(ofType: NameInputViewController.self)
        
        viewController.entryRoute = .addFriendAtFriends
        viewController.addFriendDelegate = self
        let navController = UINavigationController(rootViewController: viewController)
        self.present(navController, animated: true, completion: nil)
    }
}

extension FriendsViewController: UITableViewDelegate {
    private func initTableView() {
        tableView.delegate = self; tableView.dataSource = self
        
        let cells = [FriendsHeaderViewCell.self, FriendViewCell.self]
        tableView.register(cells)
        
        tableView.contentInset.bottom = Const.bottomInset
    }
}

extension FriendsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section),
            (section == .favorite || section == .friends) else { return 1 }
        return friends.count
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
            let friend = friends[indexPath.row]
            cell.nameLabel.text = friend.name
            cell.configure(line: indexPath.row == (friends.count - 1))
            return cell
        }
    }
}
