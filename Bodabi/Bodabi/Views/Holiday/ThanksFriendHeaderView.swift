//
//  ThanksFriendHeaderView.swift
//  Bodabi
//
//  Created by Kim DongHwan on 05/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

protocol ThanksFriendHeaderViewDelegate: class {
    func didTapSortButton(_ headerView: ThanksFriendHeaderView)
    func didTapSearchButton(_ headerView: ThanksFriendHeaderView)
}

class ThanksFriendHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var headerTitleLabel: UILabel!
    
    weak var delegate: ThanksFriendHeaderViewDelegate?
    
    @IBAction func touchUpSortButton(_ sender: UIButton) {
        delegate?.didTapSortButton(self)
    }
    
    @IBAction func touchUpSearchButton(_ sender: UIButton) {
         delegate?.didTapSearchButton(self)
    }
}
