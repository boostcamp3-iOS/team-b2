//
//  FriendHistoryViewController.swift
//  Bodabi
//
//  Created by jaehyeon lee on 25/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class FriendHistoryViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var floatingButton: UIButton!
    
    // MARK: - Property
    
    public var friendId: Int?
    private struct Const {
        static let bottomInset: CGFloat = 90.0
    }
    private var isSortDescending: Bool = true
    private var sections: [FriendHistorySection] = []
    private var histories: [History] = [History]() {
        didSet {
            sections = []
            var income: Int = 0
            var expenditure: Int = 0
            var historyItems: [FriendHistorySectionItem] = []
//            for history in histories {
//                if let amount = Int(history.item) {
//                    switch history.isTaken {
//                    case true:
//                        income += amount
//                    case false:
//                        expenditure += amount
//                    }
//                }
//                if history.isTaken == true {
//                    historyItems.append(.takeHistory(history: history))
//                } else {
//                    historyItems.append(.giveHistory(history: history))
//                }
//            }
            sections.append(.information(items: [.information(income: String(income), expenditure: String(expenditure))]))
            sections.append(.history(items: historyItems))
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        initHistories()
        initTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
        navigationController?.popToRootViewController(animated: false)
    }
    
    // MARK: - Initialization
    
    private func initHistories() {
//        let friendHistories = History.dummies.filter {
//            $0.friendId == friendId ?? 0
//        }
//        histories = friendHistories
//        sortHistories(descending: false)
    }
    
    private func initNavigationBar() {
        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationItem.title = Friend.dummies[friendId ?? 0].name
    }
    
    private func initTableView() {
        tableView.delegate = self; tableView.dataSource = self
        
        let cells = [FriendHistoryInformationViewCell.self, FriendHistoryReceiveViewCell.self, FriendHistorySendViewCell.self]
        tableView.register(cells)
        
        let nib = UINib(nibName: "FriendHistoryHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: FriendHistoryHeaderView.reuseIdentifier)
        
        tableView.contentInset.bottom = Const.bottomInset
        tableView.reloadData()
    }
    
    // MARK: - Method
    
    func sortHistories(descending: Bool) {
//        if descending == true {
//            histories = histories.sorted(by: {$0.date > $1.date})
//        } else {
//            histories = histories.sorted(by: {$0.date < $1.date})
//        }
    }
    
    // MARK: - IBAction
    
    @IBAction func touchUpFloatingButotn(_ sender: UIButton) {
        let viewController = storyboard(.input)
            .instantiateViewController(ofType: HolidayInputViewController.self)
        let navController = UINavigationController(rootViewController: viewController)
        
        viewController.entryRoute = .addHistoryAtFriendHistory
        present(navController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension FriendHistoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        let item = section.items[indexPath.row]
        let cell = tableView.dequeue(section.cellType(item), for: indexPath)
        (cell as? FriendHistoryCellProtocol)?.bind(item: item)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension FriendHistoryViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        guard scrollView.contentOffset.y > 0 else {
            scrollView.contentOffset.y = 0
            return
        }
        guard let informationCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? FriendHistoryInformationViewCell else {
            return
        }
        informationCell.incomeLabel.alpha = CGFloat(min(1.2 - Double(offsetY) * 0.023, 1.0))
        informationCell.expenditureLabel.alpha = CGFloat(min(1.2 - Double(offsetY) * 0.04, 1.0))
        informationCell.incomeIcon.alpha = CGFloat(min(1.2 - Double(offsetY) * 0.023, 1.0))
        informationCell.expenditureIcon.alpha = CGFloat(min(1.2 - Double(offsetY) * 0.04, 1.0))
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: FriendHistoryHeaderView.reuseIdentifier)
            let header = cell as! FriendHistoryHeaderView
            header.headerTitleLabel.text = "주고받은 내역"
            header.delegate = self
            return header
        } else {
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 60
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            cell.transform = CGAffineTransform(translationX: 0, y: cell.frame.height / 2)
            cell.alpha = 0
            UIView.animate(withDuration: 0.5,
                           delay: 0.05 * Double(indexPath.row),
                           options: UIView.AnimationOptions.curveEaseOut,
                           animations: {
                            cell.transform = CGAffineTransform(translationX: 0, y: 0)
                            cell.alpha = 1
            })
        }
    }
}

// MARK: - FriendHistoryHeaderViewDelegate

extension FriendHistoryViewController: FriendHistoryHeaderViewDelegate {
    func friendHistoryHeaderView(_ headerView: FriendHistoryHeaderView, didTapSortButtonWith descending: Bool) {
        sortHistories(descending: isSortDescending)
        tableView.reloadData()
        isSortDescending = !isSortDescending
    }
}

// MARK: - Type

extension FriendHistorySection {
    func cellType(_ item: FriendHistorySectionItem) -> UITableViewCell.Type {
        switch item {
        case .information:
            return FriendHistoryInformationViewCell.self
        case .giveHistory:
            return FriendHistorySendViewCell.self
        case .takeHistory:
            return FriendHistoryReceiveViewCell.self
        }
    }
}

// MARK: - Cell Protocol

protocol FriendHistoryCellProtocol {
    func bind(item: FriendHistorySectionItem)
}
