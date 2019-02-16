//
//  CalendarView.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 31..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import Foundation
import UIKit

// MARK: - CalendarViewDelegate

@objc
protocol CalendarViewDelegate: class {
    @objc optional func calendar(_ calendar: CalendarView, currentVisibleItem date: Date)
    @objc optional func calendar(_ calendar: CalendarView, didSelectedItem date: Date)
}

// MARK: - CalendarView

class CalendarView: UIView {
    
    // MARK: - Property
    
    public weak var delegate: CalendarViewDelegate? {
        didSet {
            setPageFirstView()
        }
    }
    
    public var pageContainerView: UIView?
    public var pageController: UIPageViewController?
    public var currentVisibleDate: Date = .init()
    
    public var style: CalendarViewStyle = .init()
    
    // MARK: - Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        pageController?.view.frame = bounds
        setPageFirstView()
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
                                              navigationOrientation: style.scrollOrientation,
                                              options: nil)
        guard let pageController = pageController else { return }
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        pageController.view.frame = bounds
        pageController.delegate = self; pageController.dataSource = self
        setPageFirstView()
        addSubview(pageController.view)
        
        findParentViewController()?.addChild(pageController)
    }
    
    // MAKR: - Method
    
    private func setPageFirstView() {
        guard let pageController = pageController else { return }
        if let firstPageController = pageViewController(date: currentVisibleDate) {
            pageController.setViewControllers([firstPageController],
                                              direction: .forward,
                                              animated: false,
                                              completion: nil)
            
            delegate?.calendar?(self, currentVisibleItem: currentVisibleDate)
        }
    }
    
    public func movePage(to date: Date?) {
        if let viewController = pageController?
            .viewControllers?.first as? CalendarMonthViewController {
            guard let toDate = date,
                let fromDate = viewController.visibleMonthFirstDay else { return }
            let visibleDateString = fromDate.toString(of: .noDay)
            let dateToMoveString = toDate.toString(of: .noDay)
            
            guard visibleDateString != dateToMoveString else { return }
            setNextPageView(fromDate: fromDate, toDate: toDate)
        }
    }
    
    public func movePage(addMonth count: Int) {
        if let viewController = pageController?
            .viewControllers?.first as? CalendarMonthViewController {
            guard let toDate = viewController.getDate(addMonth: count),
                let fromDate = viewController.visibleMonthFirstDay else { return }
            setNextPageView(fromDate: fromDate, toDate: toDate)
        }
    }
    
    private func setNextPageView(fromDate: Date, toDate: Date) {
        let direction: UIPageViewController.NavigationDirection =
            fromDate > toDate ? .reverse : .forward
        
        if let nextPageController = pageViewController(date: toDate) {
            pageController?.setViewControllers([nextPageController],
                                               direction: direction,
                                               animated: true,
                                               completion: nil)
            delegate?.calendar?(self, currentVisibleItem: toDate)
        }
    }
}

// MARK: - UIPageViewControllerDelegate

extension CalendarView: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let viewController = previousViewControllers
            .first as? CalendarMonthViewController {
            viewController.isVisible = false
        }
        
        if let viewController = pageViewController
            .viewControllers?.first as? CalendarMonthViewController {
            viewController.isVisible = true
            
            guard let date = viewController.visibleMonthFirstDay else { return }
            delegate?.calendar?(self, currentVisibleItem: date)
        }
    }
}

// MARK: - UIPageViewControllerDataSource

extension CalendarView: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? CalendarMonthViewController else { return nil }
        let previousDate = viewController.getDate(addMonth: -1)
        return self.pageViewController(date: previousDate)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? CalendarMonthViewController else { return nil }
        let nextDate = viewController.getDate(addMonth: 1)
        return self.pageViewController(date: nextDate)
    }
    
    private func pageViewController(date: Date?) -> UIViewController? {
        guard let date = date else { return nil }
        
        let viewController = CalendarMonthViewController()
        viewController.delegate = delegate
        viewController.superFrame = bounds
        viewController.style = style
        
        viewController.setCurrentVisibleMonth(date: date)
        return viewController
    }
}
