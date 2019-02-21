//
//  FriendHistoryHeaderView.swift
//  Bodabi
//
//  Created by jaehyeon lee on 31/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

protocol FriendHistoryHeaderViewDelegate: class {
    func friendHistoryHeaderView(_ headerView: FriendHistoryHeaderView, didTapSortButtonWith descending: Bool)
}

class FriendHistoryHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var headerTitleLabel: UILabel!
    
    // MARK: - Property
    
    var isSortDescending: Bool = true
    weak var delegate: FriendHistoryHeaderViewDelegate?
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        headerTitleLabel.text = "주고받은 내역"
    }
    
    // MARK: - IBAction

    @IBAction func touchUpSortButton(_ sender: UIButton) {
        delegate?.friendHistoryHeaderView(self, didTapSortButtonWith: isSortDescending)
    }
}
