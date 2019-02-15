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
    func didTapCancelButton(_ searchBar: UISearchBar)
    func searchBar(_ searchBar: UISearchBar, searchBarTextDidChange searchText: String)
    func didBeginEditing(_ searchBar: UISearchBar)
}

class ThanksFriendHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    weak var delegate: ThanksFriendHeaderViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initSearchBar()
    }
    
    private func initSearchBar() {
        searchBar.delegate = self
        searchBar.barTintColor = .white
        searchBar.textField?.backgroundColor = #colorLiteral(red: 0.9471639661, green: 0.9471639661, blue: 0.9471639661, alpha: 1)
        searchBar.placeholder = "검색"
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    @IBAction func touchUpSortButton(_ sender: UIButton) {
        delegate?.didTapSortButton(self)
    }
}

extension ThanksFriendHeaderView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchBar(searchBar, searchBarTextDidChange: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchBar.cancelButton?.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        searchBar.cancelButton?.setTitle("취소  ", for: .normal)
        
        delegate?.didBeginEditing(searchBar)
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        delegate?.didTapCancelButton(searchBar)
    }
}

private extension UISearchBar {
    var textField: UITextField? {
        guard let textField = value(forKey: "searchField") as? UITextField else { return nil }
        return textField
    }
    
    var cancelButton: UIButton? {
        guard let cancelButton = value(forKey: "cancelButton") as? UIButton else { return nil }
        return cancelButton
    }
}
