//
//  HolidayViewController.swift
//  Bodabi
//
//  Created by Kim DongHwan on 28/01/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit
import CoreData
import Photos

class HolidayViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var floatingButton: UIButton!
    @IBOutlet weak var holidayImageView: UIImageView!
    @IBOutlet weak var informationView: UIView!
    
    // MARK: - Properties
    
    public var entryRoute: EntryRoute!
    public var holiday: Holiday?
    
    private struct Const {
        static let bottomInset: CGFloat = 90.0
    }
    
    private var databaseManager: DatabaseManager!
    private let picker = UIImagePickerController()
    private var holidayImage: UIImage? {
        didSet {
            holidayImageView.image = holidayImage
        }
    }
    private var thanksFriends: [ThanksFriend]? = []
    private var originalBottomConstraint: CGFloat = 0.0
    
    // MARK: - Lifecycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.allowsEditing = true
        
        initTableView()
        initNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    private func shouldAccessPhotoLibrary() -> Bool {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
        case .authorized:
            return true
        case .notDetermined,
             .denied,
             .restricted:
            PHPhotoLibrary.requestAuthorization { (status) in
                switch status {
                case .denied:
                    DispatchQueue.main.async {
                        let alert = BodabiAlertController(title: "주의", message: "사진 접근 권한이 허용되지 않았습니다. [설정]으로 이동하여 접근을 허용해주세요.", type: nil, style: .Alert)
                        
                        alert.cancelButtonTitle = "확인"
                        alert.show()
                    }
                default:
                    break
                }
            }
            
            return false
        }
    }
    
    private func shouldAccessCamera() -> Bool {
        let cameraAuthorizationStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch cameraAuthorizationStatus {
        case .authorized:
            return true
        case .denied,
             .notDetermined,
             .restricted:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
                if !granted {
                    DispatchQueue.main.async {
                        let alert = BodabiAlertController(title: "주의", message: "카메라 접근 권한이 허용되지 않았습니다. [설정]으로 이동하여 접근을 허용해주세요.", type: nil, style: .Alert)
                        
                        alert.cancelButtonTitle = "확인"
                        alert.show()
                    }
                }
            }
            
            return false
        }
    }
    
    // MARK: - @IBAction
    
    @IBAction func touchUpFloatingButotn(_ sender: UIButton) {
        let viewController = storyboard(.input)
            .instantiateViewController(ofType: NameInputViewController.self)
        let navController = UINavigationController(rootViewController: viewController)
        
        viewController.setDatabaseManager(databaseManager)
        
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
        
        if !shouldAccessPhotoLibrary() { return }
        if source == .camera, !shouldAccessCamera() { return }
        
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


