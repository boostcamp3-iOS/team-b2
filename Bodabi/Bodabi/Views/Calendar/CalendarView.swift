//
//  CalendarView.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 31..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Foundation
import UIKit

enum FirstWeekType {
    case monday
    case sunday
}

enum CalendarSelectType {
    case squre
    case round
}

enum CalendarWeekType {
    case long
    case nomal
    case short
}

@objc
protocol CalendarViewDelegate: class {
    @objc optional func calendar(_ calendar: CalendarView, currentVisibleItem date: Date)
    @objc optional func calendar(_ calendar: CalendarView, didSelectedItem date: Date)
}

class CalendarView: UIView {
    
    weak var delegate: CalendarViewDelegate? {
        didSet {
            guard let pageController = pageController else { return }
            if let firstPageController = pageViewController(date: currentVisibleDate) {
                delegate?.calendar?(self, currentVisibleItem: currentVisibleDate)
                pageController.setViewControllers([firstPageController],
                                                  direction: .forward,
                                                  animated: false,
                                                  completion: nil)
            }
        }
    }
    
    public var pageContainerView: UIView?
    public var pageController: UIPageViewController?
    public var currentVisibleDate: Date = .init()
    
    struct Style {
        static var scrollOrientation: UIPageViewController.NavigationOrientation = .horizontal
        
        static var firstWeekType: FirstWeekType = .sunday
        static var selectedType: CalendarSelectType = .round
        static var weekType: CalendarWeekType = .short
        
        static var weekendColor: UIColor = .red
        static var weekColor: UIColor = .gray
        static var dayColor: UIColor = .black
        static var todayColor: UIColor = .blue
        static var selectedColor: UIColor = .yellow
        static var eventColor: UIColor = .red
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setUpUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        pageController = UIPageViewController(transitionStyle: .scroll,
                                              navigationOrientation: Style.scrollOrientation,
                                              options: nil)
        guard let pageController = pageController else { return }
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        pageController.view.frame = self.bounds
        pageController.delegate = self; pageController.dataSource = self
        addSubview(pageController.view)
        
        findParentViewController()?.addChild(pageController)
    }
    
    public func movePage(to date: Date?) {
        guard let date = date, currentVisibleDate != date else { return }
        
        let direction: UIPageViewController.NavigationDirection
            = currentVisibleDate > date ? .reverse : .forward
        
        if let nextPageController = pageViewController(date: date) {
            pageController?.setViewControllers([nextPageController],
                                               direction: direction,
                                               animated: true,
                                               completion: nil)
            delegate?.calendar?(self, currentVisibleItem: date)
        }
    }
}

extension CalendarView: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let viewController
            = pageViewController.viewControllers?.first as? CalendarMonthViewController {
            guard let date = viewController.visibleMonthFirstDay else { return }
            delegate?.calendar?(self, currentVisibleItem: date)
        }
    }
}

extension CalendarView: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? CalendarMonthViewController else { return nil }
        let previousDate = viewController.getPreviousMonth(date: viewController.visibleMonthFirstDay)
        return self.pageViewController(date: previousDate)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? CalendarMonthViewController else { return nil }
        let nextDate = viewController.getNextMonth(date: viewController.visibleMonthFirstDay)
        return self.pageViewController(date: nextDate)
    }
    
    private func pageViewController(date: Date?) -> UIViewController? {
        guard let date = date else { return nil }
        
        let viewController = CalendarMonthViewController()
        viewController.delegate = delegate
        viewController.superFrame = bounds
        viewController.firstWeekday = Style.firstWeekType
        viewController.weekType = Style.weekType
        
        viewController.setCurrentVisibleMonth(date: date)
        return viewController
    }
}
