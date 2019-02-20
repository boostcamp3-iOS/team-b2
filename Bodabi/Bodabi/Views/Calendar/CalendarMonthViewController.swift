//
//  CalendarMonthViewController.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 31..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class CalendarMonthViewController: UICollectionViewController {
    
    // MARK: - Property
    
    public lazy var calendar: Calendar = {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = .current
        return gregorian
    }()
    
    public weak var delegate: CalendarViewDelegate?
    public var isVisible: Bool = true {
        didSet {
            collectionView.visibleCells.enumerated()
                .forEach { [weak self] (index, cell) in
                    print(index)
                    self?.collectionView.deselectItem(
                        at: IndexPath(item: index, section: Section.day.rawValue),
                        animated: false
                    )
                    cell.isSelected = false
            }
        }
    }
    
    public var style: CalendarViewStyle = .init()
    public var superFrame: CGRect = .init() {
        didSet {
            setUpUI()
        }
    }
    
    private var selectDay: Int?
    public var visibleMonthFirstDay: Date? {
        didSet {
            guard let visibleMonthFirstDay = visibleMonthFirstDay else { return }
            visibleMonthInfo = getMonthInfo(for: visibleMonthFirstDay)
        }
    }
    private var visibleMonthInfo: (firstDay: Int, daysTotal: Int)?
    
    
    enum Section: Int, CaseIterable {
        case week
        case day
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        initCollectionView()
    }
    
    // MARK: - Initialization
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setUpUI() {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = superFrame
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        
        /* Collection View */
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets.zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView.collectionViewLayout = layout
        collectionView.allowsMultipleSelection = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.frame = superFrame
    }
    
    private func initCollectionView() {
        let cells = [CalendarWeekDayViewCell.self, CalendarDayViewCell.self]
        collectionView?.register(cells)
    }
    
    // MAKR: - Method
    
    private func cellSize(in bounds: CGRect) -> CGSize {
        return CGSize(width: bounds.size.width / 7.0,
                      height: bounds.size.height / 7.0)
    }
    
    private func getMonthInfo(for date: Date) -> (firstDay: Int, daysTotal: Int)? {
        let firstWeekdayOfMonth = calendar.component(.weekday, from: date)
            - (style.firstWeekType == .monday ? 1 : 0)
        let firstWeekdayOfMonthIndex = (firstWeekdayOfMonth + 6) % 7
        
        guard let rangeOfDaysInMonth = calendar
            .range(of: .day, in: .month, for: date) else { return nil }
        
        return (firstDay: firstWeekdayOfMonthIndex, daysTotal: rangeOfDaysInMonth.count)
    }
    
    public func setCurrentVisibleMonth(date: Date, shouldSelectedDay: Bool = false) {
        var currentDateComponents = calendar.dateComponents(
            [.era, .year, .month, .day],
            from: date
        )
        selectDay = shouldSelectedDay ? currentDateComponents.day : nil
        currentDateComponents.day = 1
        visibleMonthFirstDay = calendar.date(from: currentDateComponents)
    }
    
    public func getDate(addMonth count: Int) -> Date? {
        guard let date = visibleMonthFirstDay else { return nil }
        var addDateComponents = DateComponents()
        addDateComponents.month = count
        return calendar.date(byAdding: addDateComponents, to: date)
    }
    
    public func sendDateForDelegate(date: Date?) {
        guard let calendarView = view.superview?.superview?.superview?.superview as? CalendarView else { return }
        delegate?.calendar?(calendarView, didSelectedItem: date ?? .init())
    }
    
}

// MARK: - UICollectionViewDelegate

extension CalendarMonthViewController {
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section),
            section == .day else { return }
        let cell = collectionView.cellForItem(at: indexPath) as? CalendarDayViewCell
        sendDateForDelegate(date: cell?.date)
    }
}

// MARK: - UICollectionViewDataSource

extension CalendarMonthViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .week:
            return 7
        case .day:
            return 7 * 6
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UICollectionViewCell() }
        switch section {
        case .week:
            let cell = collectionView.dequeue(CalendarWeekDayViewCell.self, for: indexPath)
            cell.style = style
            cell.configure(index: indexPath.item)
            return cell
        case .day:
            let cell = collectionView.dequeue(CalendarDayViewCell.self, for: indexPath)
            cell.style = style
            
            guard let visibleMonthInfo = visibleMonthInfo,
                let visibleMonthFirstDay = visibleMonthFirstDay else { return cell }
            
            var dateComponents = calendar.dateComponents(
                [.era, .year, .month],
                from: visibleMonthFirstDay
            )
            dateComponents.day = indexPath.item - visibleMonthInfo.firstDay + 1
            dateComponents.hour = 23
            dateComponents.minute = 59
            cell.date = calendar.date(from: dateComponents)
            
            cell.day = dateComponents.day ?? 0
            if cell.day == selectDay {
                cell.isSelected = true
                sendDateForDelegate(date: cell.date)
            }
            cell.configure(daysOfMonth: 1...visibleMonthInfo.daysTotal)
            
            return cell
        }
    }
}

extension CalendarMonthViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize(in: superFrame)
    }
}

//extension CalendarMonthViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        guard let section = Section(rawValue: indexPath.section),
//            section == .week else { return cellSize(in: superFrame) }
//        return CGSize(width: superFrame.size.width / 7,
//                      height: style.weekHeaderHeight)
//    }
//}
