//
//  HolidayInputViewController.swift
//  Bodabi
//
//  Created by Kim DongHwan on 26/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class HolidayInputViewController: UIViewController {
    
    @IBOutlet weak var phraseLabel: UILabel!
    weak var delegate: HomeViewController?
    var entryRoute: EntryRoute!
    
    let myHolidaies = ["+", "결혼", "생일", "돌잔치", "장례", "출산"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPhraseLabelText()
        initNavigationBar()
    }
    
    private func initPhraseLabelText() {
        switch entryRoute {
        case .addHolidayAtHome?:
            phraseLabel.text = "어떤 경조사를\n추가하시겠어요?"
        case .addUpcomingEventAtHome?,
             .addHistoryAtFriendHistory?:
            phraseLabel.text = "친구의 경조사는\n무엇입니까?"
        default:
            break
        }
    }
    
    private func initNavigationBar() {
        self.navigationController?.navigationBar.clear()
    }
    
    @IBAction func dismissInputView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension HolidayInputViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myHolidaies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "holidayCellId", for: indexPath) as? HolidayInputViewCell else { return UITableViewCell() }
        
        cell.holidayTitle.text = myHolidaies[indexPath.row]
        
        return cell
    }
}

extension HolidayInputViewController: UITableViewDelegate {
    
}
