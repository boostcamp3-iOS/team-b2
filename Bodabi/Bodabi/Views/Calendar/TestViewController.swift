//
//  TestViewController.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 31..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var currentMonthLabel: UILabel!
    @IBOutlet weak var calendarView: CalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        calendarView.delegate = self
        
        var calendarStyle: CalendarViewStyle = .init()
        calendarStyle.todayColor = .calendarTodayColor
        calendarStyle.dayColor = .black
        calendarStyle.weekColor = .calendarWeekColor
        calendarStyle.weekendColor = .red
        calendarStyle.eventColor = .mainColor
        calendarStyle.selectedColor = .calendarSelectedColor
        calendarView.style = calendarStyle
        
        calendarView.style.weekType = .normal // long short normal
        calendarView.style.firstWeekType = .sunday
    }
    
    @IBAction func preAction(_ sender: Any) {
        calendarView.movePage(addMonth: -1)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        calendarView.movePage(addMonth: 1)
    }
    
    @IBAction func goToDateAction(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        calendarView.movePage(to: formatter.date(from: "2022-08-24"))
    }
}

extension TestViewController: CalendarViewDelegate {
    func calendar(_ calendar: CalendarView, didSelectedItem date: Date) {
        print(date)
    }
    
    func calendar(_ calendar: CalendarView, currentVisibleItem date: Date) {
        self.currentMonthLabel.text = date.toString(of: .noDay)
    }
}