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
    
    struct Const {
        static let sectionInsetLength: CGFloat = 15.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initCollectionView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

extension MyHolidaysViewCell: UICollectionViewDelegate {
    private func initCollectionView() {
        collectionView.delegate = self; collectionView.dataSource = self
        
        let cells = [HolidayViewCell.self, MyHolidayInputViewCell.self]
        collectionView.register(cells)
    }
}

extension MyHolidaysViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(HolidayViewCell.self, for: indexPath)
        
        return cell
    }
}
