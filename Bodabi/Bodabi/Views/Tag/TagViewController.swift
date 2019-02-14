//
//  TagViewController.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 2. 13..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit

class TagViewController: UIViewController {

    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Property

    private var selectedTags: Set<Tag> = [] {
        didSet {
            selectedSortedTags = selectedTags
                .sorted(by: { $0.title < $1.title })
                .sorted(by: { $0.type.rawValue < $1.type.rawValue })
        }
    }
    private var selectedSortedTags: [Tag] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    struct Const {
        static let maxSelectedTagCount: Int = 3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initTableView()
        initCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initViewAppearence()
    }
    
    private func initTableView() {
        tableView.delegate = self; tableView.dataSource = self
    }
    
    private func initCollectionView() {
        collectionView.delegate = self; collectionView.dataSource = self
    }
    
    private func initViewAppearence() {
        tagView.makeShadow(opacity: 0.16, size: CGSize(width: 3, height: 6), blur: 4)
        tagView.setScaleAnimation(scale: 1.08, duration: 0.12)
    }
    
    
    @IBAction func touchUpDoneButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension TagViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return TagType.allCases.count - 1 // .contact
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Tag.items.filter { $0.type.rawValue == (section + 1) }.count + 1 // header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tagType = TagType(rawValue: indexPath.section + 1) else { return UITableViewCell() }
        let tags = Tag.items.filter { $0.type == tagType }
        
        guard indexPath.row > 0 else {
            let cell = tableView.dequeue(TagHeaderViewCell.self , for: indexPath)
            cell.tagType = tagType
            return cell
        }
        let cell = tableView.dequeue(TagViewCell.self, for: indexPath)
        cell.tagItem = tags[indexPath.row - 1] // header
        return cell
    }
}

extension TagViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tagType = TagType(rawValue: indexPath.section + 1) else { return }
        let tags = Tag.items.filter { $0.type == tagType }
        
        guard selectedTags.count < Const.maxSelectedTagCount else {
            let cell = tableView.cellForRow(at: indexPath) as? TagViewCell
            cell?.setSelected(false, animated: false)
            return
        }
        selectedTags.insert(tags[indexPath.row - 1])
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let tagType = TagType(rawValue: indexPath.section + 1) else { return }
        let tags = Tag.items.filter { $0.type == tagType }
        selectedTags.remove(tags[indexPath.row - 1])
    }
}

extension TagViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(selectedTags.count, Const.maxSelectedTagCount)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(SelectedTagViewCell.self , for: indexPath)
        cell.tagItem = selectedSortedTags[indexPath.item]
        return cell
    }
}

extension TagViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (selectedSortedTags[indexPath.row].title as NSString).size(withAttributes: nil).width + 14.0
        return CGSize(width: width, height: 16.0)
    }
}
