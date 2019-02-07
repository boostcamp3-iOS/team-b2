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
    @IBOutlet weak var informationView: UIView!
    
    // MARK: - Properties
    
    public var databaseManager: DatabaseManager?
    public var entryRoute: EntryRoute!

    private struct Const {
        static let bottomInset: CGFloat = 90.0
    }
    
    private let picker = UIImagePickerController()
    private var holidayImage: UIImage?
    private var thanksFriends: [ThanksFriend]? = []
    private var originalBottomConstraint: CGFloat = 0.0
    
    public var holiday: Holiday?
    
    // MARK: - Lifecycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.allowsEditing = true
        
        initTableView()
        initNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchHistory()
    }
    
    // MARK: - Initialization Methods

    private func fetchHistory() {
        let request: NSFetchRequest<History> = History.fetchRequest()
        let firstPredicate = NSPredicate(format: "holiday = %@", holiday?.title ?? "")
        let secondPredicate = NSPredicate(format: "isTaken = %@", NSNumber(value: true))

        let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [firstPredicate, secondPredicate])
        request.predicate = andPredicate
        
        do {
            if let result: [History] = try databaseManager?.viewContext.fetch(request) {
                thanksFriends?.removeAll()
                for history in result {
                    thanksFriends?.append(ThanksFriend(name: history.friend?.name ?? "", item: history.item ?? ""))
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        tableView.reloadData()
    }
    
    private func initTableView() {
        tableView.delegate = self; tableView.dataSource = self
        
        let nib = UINib(nibName: "ThanksFriendHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: ThanksFriendHeaderView.reuseIdentifier)
        
        tableView.contentInset.bottom = Const.bottomInset
        
        tableView.register(ThanksFriendViewCell.self)
    }
    
    private func initNavigationBar() {
        navigationController?.view.backgroundColor = .clear
        navigationItem.title = holiday?.title
    }
    
    // MARK: - @IBAction
    
    @IBAction func touchUpFloatingButotn(_ sender: UIButton) {
        let viewController = storyboard(.input)
            .instantiateViewController(ofType: NameInputViewController.self)
        let navController = UINavigationController(rootViewController: viewController)
        
        if let databaseManager = databaseManager {
            viewController.setDatabaseManager(databaseManager)
        }
        
        var inputData = InputData()
        inputData.date = holiday?.date
        inputData.holiday = holiday?.title
        viewController.inputData = inputData
        viewController.entryRoute = .addHistoryAtHoliday
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y
//        guard scrollView.contentOffset.y > 0 else {
//            scrollView.contentOffset.y = 0
//            return
//        }
        
//        bottomConstriant.constant = -50
//        informationView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
//        heightConstriant.constant = 0
        
//        UIView.animate(withDuration: 0.5) {
//            self.view.layoutIfNeeded()
//        }
        
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ThanksFriendHeaderView.reuseIdentifier) as? ThanksFriendHeaderView else { return UIView() }
        
        header.headerTitleLabel.text = "감사한 사람들"
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 60
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

extension HolidayViewController: DatabaseManagerClient {
    func setDatabaseManager(_ manager: DatabaseManager) {
        databaseManager = manager
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


