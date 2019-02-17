//
//  HomeViewController.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 25..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Property
    
    private var databaseManager: DatabaseManager!
    private var events: [Event]?
    private var holidays: [Holiday]?
    private var isEventEmpty: Bool = true
    private var isHolidayEmpty: Bool = true
    
    struct Const {
        static let bottomInset: CGFloat = 60.0
        static let dayHours: Int = 24 * 3600
        static let buttonAnimationScale: CGFloat = 1.35
        static let buttonAnimationDuration: TimeInterval = 0.12
    }
    
    enum Section: Int, CaseIterable {
        case holidaysHeader
        case holidays
        case friendEventsHeader
        case friendEvents
        
        public var title: String {
            switch self {
            case .holidaysHeader:
                return "나의 경조사"
            case .friendEventsHeader:
                return "다가오는 이벤트"
            default:
                return .init()
            }
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        initTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initNavigationBar()
        fetchEvent()
        fetchHoliday()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Initialization
    
    private func initNavigationBar() {
        navigationController?.navigationBar.clear()
        navigationController?.navigationBar.isHidden = true
    }
    
    private func initTableView() {
        tableView.delegate = self; tableView.dataSource = self
        
        let cells = [HomeTitleViewCell.self, MyHolidaysViewCell.self, UpcomingEventViewCell.self]
        tableView.register(cells)
        
        tableView.contentInset.bottom = Const.bottomInset
    }
    
    // MARK: - Method
    
    private func fetchEvent() {
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortDescriptor]

        let predicate: NSPredicate = NSPredicate(format: "date >= %@", NSDate())
        request.predicate = predicate

        if let result = try? databaseManager.viewContext.fetch(request) {
//            guard events != result else { return }
            events = result
            tableView.reloadSections(
                IndexSet(integer: Section.friendEvents.rawValue),
                with: .none
            )
        }
    }
    
    private func fetchHoliday() {
        let request: NSFetchRequest<Holiday> = Holiday.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        if let result = try? databaseManager.viewContext.fetch(request) {
            holidays = result
            tableView.reloadSections(
                IndexSet(integer: Section.holidays.rawValue),
                with: .none
            )
        }
    }
    
    private func setShowTableViewCellDeleteButton(isShow: Bool) {
        let cancelDeleteModeGesture = UITapGestureRecognizer(target: self, action: #selector(tapBackground(_:)))
        isShow ? view.addGestureRecognizer(cancelDeleteModeGesture) : view.removeGestureRecognizer(cancelDeleteModeGesture)
        
        tableView.getAllIndexPathsInSection(section: Section.friendEvents.rawValue).forEach { (indexPath) in
            let cell = tableView.cellForRow(at: indexPath) as? UpcomingEventViewCell
            isShow ? cell?.showDeleteButton() : cell?.hideDeleteButton()
        }
    }
    
    private func deleteUpcomingEvent(at indexPath: IndexPath) {
        guard let event = events?[indexPath.row] else { return }
        databaseManager?.viewContext.delete(event)
        do {
            try databaseManager?.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
        events?.remove(at: indexPath.row)
        setShowTableViewCellDeleteButton(isShow: false)
        guard (events?.count ?? 0) > 0 else {
            tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }
        tableView.deleteRows(at: [indexPath],
                             with: .automatic)
    }
    
    // MARK: - @objcs
    
    @objc func touchUpAddHolidayButton(_ sender: UIButton) {
        let viewController = storyboard(.input)
            .instantiateViewController(ofType: HolidayInputViewController.self)
        let navController = UINavigationController(rootViewController: viewController)
    
        viewController.entryRoute = .addHolidayAtHome
        viewController.setDatabaseManager(databaseManager)
        viewController.inputData = InputData()
        present(navController, animated: true, completion: nil)
    }
    
    @objc func touchUpAddUpcomingEventButton(_ sender: UIButton) {
        let viewController = storyboard(.input)
            .instantiateViewController(ofType: NameInputViewController.self)
        let navController = UINavigationController(rootViewController: viewController)
        
        viewController.isRelationInput = false
        viewController.entryRoute = .addUpcomingEventAtHome
        viewController.setDatabaseManager(databaseManager)
        viewController.inputData = InputData()
        present(navController, animated: true, completion: nil)
    }
    
    @objc func touchUpUpcomingEventFavoriteButton(_ sender: UIButton) {
        sender.setScaleAnimation(scale: Const.buttonAnimationScale,
                                 duration: Const.buttonAnimationDuration)
        sender.isSelected = !sender.isSelected
        guard let event: Event = events?[sender.tag] else { return }
        guard let notifications: Set<Notification> = event.notifications as? Set<Notification> else { return }
        event.favorite = sender.isSelected
        
        if sender.isSelected {
            for days in [NotificationType.today.rawValue, NotificationType.week.rawValue] {
                let notification = Notification(context: databaseManager.viewContext)
                guard let interval: TimeInterval = TimeInterval(exactly: days * Const.dayHours * -1) else { return }
                notification.id = UUID().uuidString
                notification.date = event.date?.addingTimeInterval(interval)
                notification.event = event
                
                if let type = NotificationType(rawValue: days) {
                    NotificationSchedular.createNotification(notification: notification, notificationType: type, hour: 9, minute: 0)
                }
            }
        } else {
            notifications.forEach { notificaion in
                if let notificationDate = notificaion.date,
                    event.date?.offsetFrom(date: notificationDate) != NotificationType.normal.rawValue {
                    self.databaseManager.viewContext.delete(notificaion)
                    NotificationSchedular.deleteNotification(notification: notificaion)
                }
            }
        }
        try? databaseManager?.viewContext.save()
    }
    
    @objc func longPressUpcomingEvent(_ gesture: UILongPressGestureRecognizer) {
        setShowTableViewCellDeleteButton(isShow: true)
    }
    
    @objc func touchUpUpcomingEventDeleteButton(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? UpcomingEventViewCell,
            let indexPath = tableView.indexPath(for: cell) else { return }
        
        let alert = BodabiAlertController(title: "이벤트 삭제",
                                          message: "정말 친구의 이벤트를 삭제하시겠습니까?",
                                          type: nil, style: .Alert)
        alert.addButton(title: "확인") { [weak self] in
            self?.deleteUpcomingEvent(at: indexPath)
        }
        alert.addButton(title: "취소") { [weak self] in
            self?.setShowTableViewCellDeleteButton(isShow: false)
        }
        alert.show()
    }
    
    @objc func tapBackground(_ sender: UITapGestureRecognizer?) {
        setShowTableViewCellDeleteButton(isShow: false)
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        switch section {
        case .friendEvents:
            let event = events?[indexPath.row]
            let friend = event?.friend
            
            let viewController = storyboard(.friendHistory)
                .instantiateViewController(ofType: FriendHistoryViewController.self)
            viewController.setDatabaseManager(databaseManager)
            viewController.friendID = friend?.objectID
            
            navigationController?.pushViewController(viewController, animated: true)
        default:
            break
        }
    }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section),
            section == .friendEvents else {
            return 1
        }
        
        if let holidayCount = holidays?.count, holidayCount != 0 {
            isHolidayEmpty = false
        } else {
            isHolidayEmpty = true
        }
        
        if let count = events?.count, count != 0 {
            isEventEmpty = false
            return count
        } else {
            isEventEmpty = true
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .holidaysHeader:
            let cell = tableView.dequeue(HomeTitleViewCell.self, for: indexPath)
            cell.addHolidayButton.addTarget(self,
                                            action: #selector(touchUpAddHolidayButton(_:)),
                                            for: .touchUpInside)
            cell.type = section
            return cell
        case .friendEventsHeader:
            let cell = tableView.dequeue(HomeTitleViewCell.self, for: indexPath)
            cell.addHolidayButton.addTarget(self,
                                            action: #selector(touchUpAddUpcomingEventButton(_:)),
                                            for: .touchUpInside)
            cell.type = section
            return cell
        case .holidays:
            if isHolidayEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyHolidayCell", for: indexPath)
                return cell
            } else {
                let cell = tableView.dequeue(MyHolidaysViewCell.self, for: indexPath)
                cell.collectionView.delegate = self
                cell.holidays = holidays
                return cell
            }
        case .friendEvents:
            if isEventEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyViewCell", for: indexPath)
                return cell
            } else {
                let cell = tableView.dequeue(UpcomingEventViewCell.self, for: indexPath)
                cell.favoriteButton.tag = indexPath.row
                cell.favoriteButton
                    .addTarget(self, action: #selector(touchUpUpcomingEventFavoriteButton(_:)),  for: .touchUpInside)
                cell.deleteButton
                    .addTarget(self, action: #selector(touchUpUpcomingEventDeleteButton(_:)),
                               for: .touchUpInside)
                
                cell.event = events?[indexPath.row]
                
                let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressUpcomingEvent(_:)))
                cell.addGestureRecognizer(gesture)
                
                return cell
            }
        }
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = storyboard(.holiday)
            .instantiateViewController(ofType: HolidayViewController.self)
        viewController.setDatabaseManager(databaseManager)
        viewController.holiday = holidays?[indexPath.item]
        viewController.entryRoute = .addHistoryAtFriendHistory
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - DatabaseManagerClient

extension HomeViewController: DatabaseManagerClient {
    func setDatabaseManager(_ manager: DatabaseManager) {
        databaseManager = manager
    }
}
