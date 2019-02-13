//
//  FriendHistoryViewController.swift
//  Bodabi
//
//  Created by jaehyeon lee on 25/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit
import CoreData

class FriendHistoryViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var floatingButton: UIButton!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    // MARK: - Property
    
    internal var friend: Friend? {
        didSet {
            histories = (friend?.histories as? Set<History>)?.sorted(by: { $0.date! < $1.date! }) ?? []
        }
    }
    private var histories: [History]?
    private var databaseManager: DatabaseManager!
    private var isSortDescending: Bool = true
    private var isTableViewLoaded: Bool = false
    private var isInputStatus: Bool = false
    private var sections: [FriendHistorySection] = []
    private struct Const {
        static let bottomInset: CGFloat = 90.0
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSection()
        initNavigationBar()
        initTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isInputStatus = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !isInputStatus {
        navigationController?.popToRootViewController(animated: false)
        }
    }
    
    // MARK: - Initialization
    
    private func initNavigationBar() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.title = friend?.name ?? ""
        favoriteButton.image = friend?.favorite == true ? #imageLiteral(resourceName: "ic_emptyStar") : #imageLiteral(resourceName: "WhiteStar")
    }
    
    private func initTableView() {
        tableView.delegate = self; tableView.dataSource = self
        
        let cells = [FriendHistoryInformationViewCell.self, FriendHistoryReceiveViewCell.self, FriendHistorySendViewCell.self]
        let nib = UINib(nibName: "FriendHistoryHeaderView", bundle: nil)
        tableView.register(cells)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: FriendHistoryHeaderView.reuseIdentifier)
        tableView.contentInset.bottom = Const.bottomInset
        tableView.reloadData()
    }
    
    private func initSection() {
        guard let histories = histories else {
            return
        }
        sections = []
        var income: Int = 0
        var expenditure: Int = 0
        var historyItems: [FriendHistorySectionItem] = []
        for history in histories {
            if let amount = Int(history.item ?? "") {
                switch history.isTaken {
                case true:
                    income += amount
                case false:
                    expenditure += amount
                }
            }
            if history.isTaken == true {
                historyItems.append(.takeHistory(history: history))
            } else {
                historyItems.append(.giveHistory(history: history))
            }
        }
        sections.append(.information(items: [.information(income: String(income), expenditure: String(expenditure))]))
        sections.append(.history(items: historyItems))
    }
    
    // MARK: - Method
    
    private func sortHistories(descending: Bool) {
        if descending == true {
            histories = histories?.sorted(by: {$0.date ?? Date() > $1.date ?? Date()})
        } else {
            histories = histories?.sorted(by: {$0.date ?? Date() < $1.date ?? Date()})
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func touchUpFloatingButton(_ sender: UIButton) {
        isInputStatus = true
        let viewController = storyboard(.input)
            .instantiateViewController(ofType: HolidayInputViewController.self)
        let navigationController = UINavigationController(rootViewController: viewController)
        
        var inputData = InputData()
        inputData.name = friend?.name
        
        viewController.inputData = inputData
        viewController.entryRoute = .addHistoryAtFriendHistory
        viewController.setDatabaseManager(databaseManager)
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func touchUpFavoriteButton(_ sender: UIBarButtonItem) {
        if favoriteButton.image == #imageLiteral(resourceName: "ic_emptyStar") {
            friend?.favorite = false
            favoriteButton.image = #imageLiteral(resourceName: "WhiteStar")
            try? databaseManager?.viewContext.save()
        } else {
            friend?.favorite = true
            favoriteButton.image = #imageLiteral(resourceName: "ic_emptyStar")
            try? databaseManager?.viewContext.save()
        }
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
        guard let informationCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? FriendHistoryInformationViewCell else {
            return
        }
        informationCell.incomeLabel.alpha = CGFloat(min(1.2 - Double(offsetY) * 0.023, 1.0))
        informationCell.expenditureLabel.alpha = CGFloat(min(1.2 - Double(offsetY) * 0.04, 1.0))
        informationCell.incomeIcon.alpha = CGFloat(min(1.2 - Double(offsetY) * 0.023, 1.0))
        informationCell.expenditureIcon.alpha = CGFloat(min(1.2 - Double(offsetY) * 0.04, 1.0))
        
        guard scrollView.contentOffset.y > 0 else {
            scrollView.contentOffset.y = 0
            return
        }
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
        if indexPath.section == 1, isTableViewLoaded == false {
            cell.transform = CGAffineTransform(translationX: 0, y: cell.frame.height / 2)
            cell.alpha = 0
            UIView.animate(withDuration: 0.5,
                           delay: 0.05 * Double(indexPath.row),
                           options: .curveEaseOut,
                           animations: { cell.transform = CGAffineTransform(translationX: 0, y: 0)
                                         cell.alpha = 1 },
                           completion: { _ in self.isTableViewLoaded = true })
        }
    }
}

// MARK: - FriendHistoryHeaderViewDelegate

extension FriendHistoryViewController: FriendHistoryHeaderViewDelegate {
    func friendHistoryHeaderView(_ headerView: FriendHistoryHeaderView, didTapSortButtonWith descending: Bool) {
        sortHistories(descending: isSortDescending)
        isTableViewLoaded = false
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

// MARK: - DatabaseManagerClient

extension FriendHistoryViewController: DatabaseManagerClient {
    func setDatabaseManager(_ manager: DatabaseManager) {
        databaseManager = manager
    }
}

// MARK: - Cell Protocol

protocol FriendHistoryCellProtocol {
    func bind(item: FriendHistorySectionItem)
}
