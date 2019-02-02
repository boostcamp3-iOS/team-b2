//
//  CalendarMonthViewController.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 31..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class CalendarMonthViewController: UICollectionViewController {
    
    public lazy var calendar : Calendar = {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = TimeZone(abbreviation: "UTC")!
        return gregorian
    }()
    
    weak var delegate: CalendarViewDelegate?
    
    // MARK: Calendar style
    
    public var style: CalendarViewStyle = .init()
    
    public var superFrame: CGRect = .init() {
        didSet {
            setUpUI()
        }
    }

    // MARK: Properties
    
    public var visibleMonthFirstDay: Date? {
        didSet {
            guard let visibleMonthFirstDay = visibleMonthFirstDay else { return }
            visibleMonthInfo = getMonthInfo(for: visibleMonthFirstDay)
        }
    }
    var visibleMonthInfo: (firstDay: Int, daysTotal: Int)?
    
    
    enum Section: Int, CaseIterable {
        case week
        case day
    }
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        initCollectionView()
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
        layout.itemSize = cellSize(in: superFrame)
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
    
    public func setCurrentVisibleMonth(date: Date) {
        var currentDateComponents = calendar.dateComponents([.era, .year, .month],
                                                            from: date)
        currentDateComponents.day = 1
        visibleMonthFirstDay = calendar.date(from: currentDateComponents)
    }
    
    public func getNextMonth(date: Date?) -> Date? {
        guard let date = date else { return nil }
        var addDateComponents = DateComponents()
        addDateComponents.month = 1
        return calendar.date(byAdding: addDateComponents, to: date)
    }
    
    public func getPreviousMonth(date: Date?) -> Date? {
        guard let date = date else { return nil }
        var addDateComponents = DateComponents()
        addDateComponents.month = -1
        return calendar.date(byAdding: addDateComponents, to: date)
    }
    
    private func cellSize(in bounds: CGRect) -> CGSize {
        return CGSize(width:   bounds.size.width / 7.0,
                      height: bounds.size.height / 7.0)
    }
    
    private func getMonthInfo(for date: Date) -> (firstDay: Int, daysTotal: Int)? {
        var firstWeekdayOfMonthIndex    = calendar.component(.weekday, from: date)
        firstWeekdayOfMonthIndex       -= style.firstWeekType == .monday ? 1 : 0
        firstWeekdayOfMonthIndex        = (firstWeekdayOfMonthIndex + 6) % 7
        
        guard let rangeOfDaysInMonth
            = calendar.range(of: .day, in: .month, for: date) else { return nil }
        
        return (firstDay: firstWeekdayOfMonthIndex, daysTotal: rangeOfDaysInMonth.count)
    }
    
}

extension CalendarMonthViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section),
            section == .day else { return }
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = style.selectedColor
        
        guard let visibleMonth = visibleMonthFirstDay,
            let visibleMonthInfo = visibleMonthInfo else { return }
        var dateComponents = calendar.dateComponents([.era, .year, .month], from: visibleMonth)
        dateComponents.day = indexPath.item - visibleMonthInfo.firstDay + 1
        
        guard let calendarView = view.superview?.superview?.superview?.superview as? CalendarView,
            let selectedDate = calendar.date(from: dateComponents) else { return }
        delegate?.calendar?(calendarView, didSelectedItem: selectedDate)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section),
            section == .day else { return }
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = .clear
    }
}

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
            cell.configure(weekType: style.weekType, weekDay: indexPath.item)
            let isWeekend = style.firstWeekType == .monday ? (indexPath.item == 5 || indexPath.item == 6) : (indexPath.item == 0 || indexPath.item == 6)
            cell.setWeekend(isWeekend,
                            weekendColor: style.weekendColor,
                            weekColor: style.weekColor)
            return cell
        case .day:
            let cell = collectionView.dequeue(CalendarDayViewCell.self, for: indexPath)
            cell.selectedType = .round
            var events: [Int] = []
            if indexPath.item % 15 == 0 {
                events = [1]
            }
            cell.configure(indexPath.row - (visibleMonthInfo?.firstDay ?? 0) + 1,
                           isDayOfMonth: (visibleMonthInfo?.firstDay ?? 0)..<(visibleMonthInfo?.firstDay ?? 0)+(visibleMonthInfo?.daysTotal ?? 0) ~= indexPath.row, events: events)
            cell.eventView.backgroundColor = style.eventColor
            
            let currentMonth = calendar.component(.month, from: visibleMonthFirstDay ?? Date())
            let todayMonthComponents = calendar.dateComponents([.month, .day], from: Date())
            if currentMonth == todayMonthComponents.month ?? 0 {
                let isToday = indexPath.item + 1 ==
                    (todayMonthComponents.day ?? 0) + (visibleMonthInfo?.firstDay ?? 0)
                
                cell.setToday(isToday,
                              todayColor: style.todayColor,
                              dayColor: style.dayColor)
            }
            return cell
        }
    }
}
