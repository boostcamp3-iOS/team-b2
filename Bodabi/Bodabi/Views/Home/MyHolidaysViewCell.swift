//
//  MyHolidaysViewCell.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 25..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class MyHolidaysViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    enum Section: Int, CaseIterable {
        case holidays
        case holidayInput
    }
    
    struct Const {
        static let sectionInsetLength: CGFloat = 15.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

extension MyHolidaysViewCell: UICollectionViewDelegate {
    private func setUpUI() {
        collectionView.delegate = self; collectionView.dataSource = self
        
        let cells = [HolidayViewCell.self, MyHolidayInputViewCell.self]
        collectionView.register(cells)
    }
}

extension MyHolidaysViewCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section),
            section == .holidays else {
            return 1
        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section),
            section == .holidays else {
                let cell = collectionView.dequeue(MyHolidayInputViewCell.self, for: indexPath)
                return cell
        }
        
        let cell = collectionView.dequeue(HolidayViewCell.self, for: indexPath)
        return cell
    }
}

extension MyHolidaysViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var inset = UIEdgeInsets(top: 0,
                                 left: Const.sectionInsetLength,
                                 bottom: 0,
                                 right: Const.sectionInsetLength)
        
        guard let section = Section(rawValue: section),
            section == .holidays else {
                inset.left = 0
                return inset
        }
        inset.left = Const.sectionInsetLength
        return inset
    }
}
