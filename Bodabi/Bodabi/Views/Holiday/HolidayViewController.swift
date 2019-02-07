//
//  HolidayViewController.swift
//  Bodabi
//
//  Created by Kim DongHwan on 28/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit
import CoreData

class HolidayViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var floatingButton: UIButton!
    
    // MARK: - Properties
    
    private let picker = UIImagePickerController()
    
    public var entryRoute: EntryRoute!
    private struct Const {
        static let bottomInset: CGFloat = 90.0
    }
    private var holidayImage: UIImage?
    private var databaseManager: DatabaseManager?
    private var thanksFriends: [ThanksFriend]?
    
    // MARK: - Lifecycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.allowsEditing = true
        
        initTableView()
        initNavigationBar()
    }
    
    // MARK: - Initialization Methods
    
    private func initTableView() {
        tableView.delegate = self; tableView.dataSource = self
        
        let nib = UINib(nibName: "ThanksFriendHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: ThanksFriendHeaderView.reuseIdentifier)
        
        tableView.contentInset.bottom = Const.bottomInset
        
        tableView.register(ThanksFriendViewCell.self)
        
        thanksFriends?.append(ThanksFriend(name: "김철수", item: "50,000"))
        thanksFriends?.append(ThanksFriend(name: "박영희", item: "20,000"))

//        thankFriends.append((items: [
//            HolidaySectionItem.thanksFriend(name: "김철수", item: "50,000"),
//            HolidaySectionItem.thanksFriend(name: "박영희", item: "30,000"),
//            HolidaySectionItem.thanksFriend(name: "문재인", item: "500,000"),
//            HolidaySectionItem.thanksFriend(name: "성시경", item: "50,000"),
//            HolidaySectionItem.thanksFriend(name: "김미영", item: "전자레인지"),
//            HolidaySectionItem.thanksFriend(name: "박영민", item: "100,000"),
//            HolidaySectionItem.thanksFriend(name: "엄마", item: "냉장고"),
//            HolidaySectionItem.thanksFriend(name: "고민준", item: "TV"),
//            HolidaySectionItem.thanksFriend(name: "김철수", item: "50,000"),
//            HolidaySectionItem.thanksFriend(name: "김철수", item: "50,000"),
//            HolidaySectionItem.thanksFriend(name: "김철수", item: "50,000"),
//            HolidaySectionItem.thanksFriend(name: "김철수", item: "50,000")]))
    }
    
    private func initNavigationBar() {
        navigationController?.view.backgroundColor = .clear
    }
    
    // MARK: - @IBAction
    
    @IBAction func touchUpFloatingButotn(_ sender: UIButton) {
        let viewController = storyboard(.input)
            .instantiateViewController(ofType: NameInputViewController.self)
        let navController = UINavigationController(rootViewController: viewController)
        
        viewController.entryRoute = .addFriendAtHoliday
        present(navController, animated: true, completion: nil)
    }
    
    @IBAction func touchUpCameraButton(_ sender: UIBarButtonItem) {
        let actionSheet = BodabiAlertController(type: .camera(SourceTypes: [.camera, .savedPhotosAlbum, .photoLibrary]), style: .ActionSheet)
        actionSheet.delegate = self
        actionSheet.show()
    }
    
    // MARK: - @objc
    
    @objc func popCurrentInputView(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension HolidayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thanksFriends?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let thanksFriend = thanksFriends?[indexPath.row] else { return UITableViewCell() }
        let cell = tableView.dequeue(ThanksFriendViewCell.self, for: indexPath)
        cell.bind(friend: thanksFriend)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
}

// MARK: - UITableViewDelegate

extension HolidayViewController: UITableViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y
//        guard scrollView.contentOffset.y > 0 else {
//            scrollView.contentOffset.y = 0
//            return
//        }
//
//        guard let informationCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? HolidayInformationViewCell else { return }
//
//        informationCell.incomeLabel.alpha = CGFloat(min(1.2 - Double(offsetY) * 0.023, 1.0))
//        informationCell.incomeIcon.alpha = CGFloat(min(1.2 - Double(offsetY) * 0.023, 1.0))
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ThanksFriendHeaderView.reuseIdentifier) as? ThanksFriendHeaderView else { return UIView() }
        
        header.headerTitleLabel.text = "감사한 사람들"
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 60
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            cell.transform = CGAffineTransform(translationX: 0, y: cell.frame.height / 2)
            cell.alpha = 0
            UIView.animate(withDuration: 0.5,
                           delay: 0.05 * Double(indexPath.row),
                           options: .curveEaseOut,
                           animations: {
                            cell.transform = CGAffineTransform(translationX: 0, y: 0)
                            cell.alpha = 1
            })
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension HolidayViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    private func presentPicker(source: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(source) else {
            let alert = BodabiAlertController(title: "사용할 수 없는 타입입니다", message: nil, type: nil, style: .Alert)
            alert.cancelButtonTitle = "확인"
            alert.show()
            
            return
        }
        
        picker.sourceType = source
        
        present(picker, animated: false)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            holidayImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            holidayImage = originalImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - BodabiAlertControllerDelegate

extension HolidayViewController: BodabiAlertControllerDelegate {
    func bodabiAlert(type: UIImagePickerController.SourceType) {
        presentPicker(source: type)
    }
}

// MARK: - Type

struct ThanksFriend {
    var name: String
    var item: String
}

// MARK: - Cell Protocol

protocol HolidayCellProtocol {
    func bind(friend: ThanksFriend)
}
