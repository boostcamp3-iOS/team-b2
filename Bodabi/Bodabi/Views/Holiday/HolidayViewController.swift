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
    @IBOutlet weak var informationView: HolidayInformationView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    
    public var entryRoute: EntryRoute!
    public var holiday: Holiday?
    
    private struct Const {
        static let bottomInset: CGFloat = 90.0
        static let cellHeight: CGFloat = 45.0
        static let headerHeight: CGFloat = 60.0
        static let maximumImageHeight: CGFloat = 350.0
        static var minimumImageHeight: CGFloat = 88.0
    }
    
    private var databaseManager: DatabaseManager!
    private var thanksFriends: [ThanksFriend]? = [] {
        didSet {
            tableView.reloadData()
        }
    }
    private var isFirstScroll: Bool = true
    
    // MARK: - Lifecycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initTableView()
        initInformationView()
        initNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchHistory()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        heightConstraint.constant = Const.minimumImageHeight
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
        setIncomeLabel()
    }
    
    private func initTableView() {
        tableView.delegate = self; tableView.dataSource = self
        
        let nib = UINib(nibName: "ThanksFriendHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: ThanksFriendHeaderView.reuseIdentifier)
        
        tableView.contentInset.bottom = Const.bottomInset
        
        tableView.register(ThanksFriendViewCell.self)
    }
    
    private func initInformationView() {
        guard let holiday = holiday else { return }
        guard let imageData = holiday.image else { return }
        informationView.holidayImageView.image = UIImage(data: imageData)
        informationView.blurView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        informationView.incomeIcon.image = #imageLiteral(resourceName: "ic_boxIn")
    }
    
    private func initNavigationBar() {
        navigationController?.view.backgroundColor = .clear
        navigationItem.title = holiday?.title
    }
    
    private func setIncomeLabel() {
        guard let thanksFriends = thanksFriends else { return }
        
        let totallyIncome = thanksFriends.reduce(0) {
            if let income = Int($1.item) {
                return $0 + income
            } else { return $0 }
        }
        
        informationView.incomeLabel.text = String(totallyIncome).insertComma()
    }
    
    private func shouldAccessPhotoLibrary(for source: UIImagePickerController.SourceType) -> Bool {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
        case .authorized:
            return true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                switch status {
                case .denied:
                    DispatchQueue.main.async {
                        let alert = BodabiAlertController(title: "주의", message: "사진 접근 권한이 허용되지 않았습니다. [설정]으로 이동하여 접근을 허용해주세요.", type: nil, style: .Alert)
                        
                        alert.cancelButtonTitle = "확인"
                        alert.show()
                    }
                case .authorized:
                    self.presentPicker(source: source)
                default:
                    break
                }
            }
            return false
        case .denied,
             .restricted:
            let alert = BodabiAlertController(title: "주의", message: "사진 접근 권한이 허용되지 않았습니다. [설정]으로 이동하여 접근을 허용해주세요.", type: nil, style: .Alert)
            
            alert.cancelButtonTitle = "확인"
            alert.show()
            return false
        }
    }
    
    private func shouldAccessCamera() -> Bool {
        let cameraAuthorizationStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch cameraAuthorizationStatus {
        case .authorized:
            return true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
                if !granted {
                    DispatchQueue.main.async {
                        let alert = BodabiAlertController(title: "주의", message: "카메라 접근 권한이 허용되지 않았습니다. [설정]으로 이동하여 접근을 허용해주세요.", type: nil, style: .Alert)
                        
                        alert.cancelButtonTitle = "확인"
                        alert.show()
                    }
                } else {
                    self.presentPicker(source: .camera)
                }
            }
            return false
        case .denied,
             .restricted:
            let alert = BodabiAlertController(title: "주의", message: "카메라 접근 권한이 허용되지 않았습니다. [설정]으로 이동하여 접근을 허용해주세요.", type: nil, style: .Alert)
            
            alert.cancelButtonTitle = "확인"
            alert.show()
            
            return false
        }
    }
    
    // MARK: - @IBAction
    
    @IBAction func touchUpFloatingButotn(_ sender: UIButton) {
        informationView.incomeIcon.alpha = 0
        informationView.incomeLabel.alpha = 0
        
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
    
    @IBAction func touchUpSettingButton(_ sender: UIBarButtonItem) {
        let alert = BodabiAlertController(title: "정말 삭제하시겠습니까?", message: nil, type: nil, style: .Alert)
        
        alert.addButton(title: "확인") {
            print("증말로다가 삭테한다.")
        }
        
        alert.cancelButtonTitle = "취소"
        alert.show()
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
        return Const.cellHeight
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - UITableViewDelegate

extension HolidayViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ThanksFriendHeaderView.reuseIdentifier) as? ThanksFriendHeaderView else { return UIView() }
        
        header.headerTitleLabel.text = "감사한 사람들"
        header.delegate = self
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Const.headerHeight
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            tableView.beginUpdates()
            
            thanksFriends?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            // 실제 CoreData 데이터 삭제
            tableView.endUpdates()
        default:
            break
        }
    }
}

extension HolidayViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        Const.minimumImageHeight = view.safeAreaLayoutGuide.layoutFrame.origin.y
        
        let offsetY = scrollView.contentOffset.y
        var height = heightConstraint.constant - offsetY
        
        var alpha = (height - Const.minimumImageHeight) / (Const.maximumImageHeight - Const.minimumImageHeight)

        if height < Const.minimumImageHeight {
            height = Const.minimumImageHeight
        } else if height > Const.maximumImageHeight {
            height = Const.maximumImageHeight
            isFirstScroll = false
        }
        
        if isFirstScroll, offsetY <= 0 {
            alpha = 1.0
        } else if isFirstScroll, offsetY >= 0 {
            isFirstScroll = false
        }

        informationView.incomeLabel.alpha = alpha
        informationView.incomeIcon.alpha = alpha
        
        heightConstraint.constant = height
    }
}

// MARK: - ThanksFriendHeaderViewDelegate

extension HolidayViewController: ThanksFriendHeaderViewDelegate {
    func thanksFriendHeaderView(_ headerView: ThanksFriendHeaderView) {
        let alert = BodabiAlertController(title: "정렬할 방법을 선택해주세요", message: nil, type: nil, style: .Alert)
        
        alert.addButton(title: "이름순") { [weak self] in
            self?.thanksFriends?.sort { $0.name < $1.name }
        }
        
        alert.addButton(title: "금액순") { [weak self] in
            self?.thanksFriends?.sort {
                $0.item.localizedStandardCompare($1.item) == .orderedAscending
            }
        }
        
        alert.cancelButtonTitle = "취소"
        alert.show()
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
        
        switch source {
        case .camera:
            if !shouldAccessCamera() { return }
        case .photoLibrary,
             .savedPhotosAlbum:
            if !shouldAccessPhotoLibrary(for: source) { return }
        }
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = source
        
        present(picker, animated: false)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            image = originalImage
        }
        
        guard let holidayImage = image else { return }
        
        informationView.holidayImageView.image = holidayImage
        
        guard let imageData = holidayImage.jpegData(compressionQuality: 1.0) else { return }
        
        holiday?.image = imageData
        
        do {
            try databaseManager.viewContext.save()
        } catch {
            print(error.localizedDescription)
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
