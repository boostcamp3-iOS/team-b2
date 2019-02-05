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
    private struct Const {
        static let bottomInset: CGFloat = 90.0
    }
    private var sections: [HolidaySection] = []
    
    // MARK: - Lifecycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initTableView()
        initNavigationBar()
    }
    
    // MARK: - Initialization Methods
    
    private func initTableView() {
        tableView.delegate = self; tableView.dataSource = self
        
        let nib = UINib(nibName: "ThanksFriendHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: ThanksFriendHeaderView.reuseIdentifier)
        
        let cells = [HolidayInformationViewCell.self, ThanksFriendViewCell.self]
        
        tableView.contentInset.bottom = Const.bottomInset
        
        tableView.register(cells)
        
        sections.append(HolidaySection.information(items: [HolidaySectionItem.information(income: "100,000")]))
        sections.append(HolidaySection.thanksFriend(items: [
            HolidaySectionItem.thanksFriend(name: "김철수", item: "50,000"),
            HolidaySectionItem.thanksFriend(name: "박영희", item: "30,000"),
            HolidaySectionItem.thanksFriend(name: "문재인", item: "500,000"),
            HolidaySectionItem.thanksFriend(name: "성시경", item: "50,000"),
            HolidaySectionItem.thanksFriend(name: "김미영", item: "전자레인지"),
            HolidaySectionItem.thanksFriend(name: "박영민", item: "100,000"),
            HolidaySectionItem.thanksFriend(name: "엄마", item: "냉장고"),
            HolidaySectionItem.thanksFriend(name: "고민준", item: "TV"),
            HolidaySectionItem.thanksFriend(name: "김철수", item: "50,000"),
            HolidaySectionItem.thanksFriend(name: "김철수", item: "50,000"),
            HolidaySectionItem.thanksFriend(name: "김철수", item: "50,000"),
            HolidaySectionItem.thanksFriend(name: "김철수", item: "50,000")]))
    }
    
    private func initNavigationBar() {
        navigationController?.view.backgroundColor = .clear
        navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.927362144, green: 0.4233368039, blue: 0.2925595641, alpha: 1)
    }
    
    // MARK: - @IBAction
    
    @IBAction func touchUpFloatingButotn(_ sender: UIButton) {
        let viewController = storyboard(.input)
            .instantiateViewController(ofType: NameInputViewController.self)
        let navController = UINavigationController(rootViewController: viewController)
        
        viewController.entryRoute = .addFriendAtHoliday
        present(navController, animated: true, completion: nil)
    }
    
    // MARK: - @objc
    
    @objc func popCurrentInputView(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension HolidayViewController: UITableViewDataSource {
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
        (cell as? HolidayCellProtocol)?.bind(item: item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = sections[indexPath.section]
        switch section {
        case .information:
            return 120
        default:
            return 45
        }
    }
}

// MARK: - UITableViewDelegate

extension HolidayViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        guard scrollView.contentOffset.y > 0 else {
            scrollView.contentOffset.y = 0
            return
        }
        guard let informationCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? HolidayInformationViewCell else { return }
        
        informationCell.incomeLabel.alpha = CGFloat(min(1.2 - Double(offsetY) * 0.023, 1.0))
        informationCell.incomeIcon.alpha = CGFloat(min(1.2 - Double(offsetY) * 0.023, 1.0))
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ThanksFriendHeaderView.reuseIdentifier) as? ThanksFriendHeaderView else { return UIView() }

            header.headerTitleLabel.text = "감사한 사람들"

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
                           options: .curveEaseOut,
                           animations: {
                            cell.transform = CGAffineTransform(translationX: 0, y: 0)
                            cell.alpha = 1
            })
        }
    }
}

// MARK: - Type

extension HolidayViewController {
    struct ThankFriend {
        var name: String
        var item: String
    }
}

// MARK: - Type

extension HolidaySection {
    func cellType(_ item: HolidaySectionItem) -> UITableViewCell.Type {
        switch item {
        case .information:
            return HolidayInformationViewCell.self
        case .thanksFriend:
            return ThanksFriendViewCell.self
        }
    }
}

// MARK: - Cell Protocol

protocol HolidayCellProtocol {
    func bind(item: HolidaySectionItem)
}
