//
//  HolidayInputViewController.swift
//  Bodabi
//
//  Created by Kim DongHwan on 26/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

class HolidayInputViewController: UIViewController {
    
    @IBOutlet weak var guideLabel: UILabel!
    
    weak var delegate: HomeViewController?
    var entryRoute: EntryRoute!
    var selectedHoliday: String?
    
    let myHolidaies = ["+", "결혼", "생일", "돌잔치", "장례", "출산"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initGuideLabelText()
        initNavigationBar()
    }
    
    private func initGuideLabelText() {
        guard let entryRoute = entryRoute else { return }
        switch entryRoute {
        case .addHolidayAtHome:
            guideLabel.text = "어떤 경조사를\n추가하시겠어요?"
        case .addUpcomingEventAtHome,
             .addHistoryAtFriendHistory:
            guideLabel.text = "친구의 경조사는\n무엇입니까?"
        default:
            break
        }
    }
    
    private func initNavigationBar() {
        self.navigationController?.navigationBar.clear()
    }
    
    @IBAction func touchUpHoildayButton(_ sender: UIButton) {
        selectedHoliday = sender.titleLabel?.text
    }
    
    @IBAction func touchUpNextButton(_ sender: UIButton) {
        if selectedHoliday == "+" {
            let viewController = storyboard(.input)
                .instantiateViewController(ofType: NameInputViewController.self)
            viewController.entryRoute = entryRoute
            viewController.delegate = delegate
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            delegate?.addedHoliday = selectedHoliday
            self.dismiss(animated: true, completion: nil)
        }
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
        
        cell.holidaybutton.setTitle(myHolidaies[indexPath.row], for: .normal)
        if indexPath.row == 0 {
            cell.holidaybutton.backgroundColor = UIColor.offColor
        }
        return cell
    }
}

extension HolidayInputViewController: UITableViewDelegate {
    
}
