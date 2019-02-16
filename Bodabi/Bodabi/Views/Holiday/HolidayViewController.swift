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
    private weak var textField: UITextField?
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    private var keyboardDismissGesture: UITapGestureRecognizer?
    
    // MARK: - Properties
    
    public var entryRoute: EntryRoute!
    public var holiday: Holiday?
    private var histories: [History]? {
        didSet {
            tableView.reloadData()
        }
    }
    private var searchedHistories: [History]? {
        didSet {
            tableView.reloadData()
        }
    }
    private var databaseManager: DatabaseManager!
    private var isFirstScroll: Bool = true
    private var isHolidayEmpty: Bool = true
    private struct Const {
        static let bottomInset: CGFloat = 90.0
        static let cellHeight: CGFloat = 45.0
        static let headerHeight: CGFloat = 114.0
        static let maximumImageHeight: CGFloat = 350.0
        static var minimumImageHeight: CGFloat = 88.0
    }
    
    // MARK: - Lifecycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initKeyboard()
        initTableView()
        initInformationView()
        initNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchHistory()
        setIncomeLabel()
        heightConstraint.constant = Const.maximumImageHeight
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        heightConstraint.constant = Const.minimumImageHeight
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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
                histories = result
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func initKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    private func initTextField() {
        guard let tabbarFrame = tabBarController?.tabBar.frame else { return }
        let newNameInputFrame = CGRect(x: tabbarFrame.origin.x, y: tabbarFrame.origin.y, width: tabbarFrame.width, height: tabbarFrame.height / 2)
        let newNameInputTextField = UITextField(frame: newNameInputFrame)
        newNameInputTextField.placeholder = holiday?.title
        newNameInputTextField.borderStyle = .roundedRect
        newNameInputTextField.clearButtonMode = .always
        newNameInputTextField.contentVerticalAlignment = .center
        newNameInputTextField.delegate = self
        textField = newNameInputTextField
        view.addSubview(newNameInputTextField)
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
    
        if let imageData = holiday.image {
            informationView.holidayImageView.image = UIImage(data: imageData)
            informationView.blurView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        } else {
            informationView.blurView.backgroundColor = UIColor.mainColor
        }
        
        informationView.incomeIcon.image = #imageLiteral(resourceName: "ic_boxIn")
    }
    
    private func initNavigationBar() {
        navigationController?.view.backgroundColor = .clear
        navigationItem.title = holiday?.title
    }
    
    private func setIncomeLabel() {
        guard let histories = histories else { return }
        
        let totallyIncome = histories.reduce(0) {
            if let income = Int($1.item ?? "") {
                return $0 + income
            } else { return $0 }
        }
        
        informationView.incomeLabel.text = String(totallyIncome).insertComma()
        informationView.incomeLabel.alpha = 1.0
        informationView.incomeIcon.alpha = 1.0
    }
    
    private func shouldAccessPhotoLibrary(for source: UIImagePickerController.SourceType) -> Bool {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
        case .authorized:
            return true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] (status) in
                switch status {
                case .denied:
                    DispatchQueue.main.async {
                        let alert = BodabiAlertController(title: "주의", message: "사진 접근 권한이 허용되지 않았습니다. [설정]으로 이동하여 접근을 허용해주세요.", type: nil, style: .Alert)
                        
                        alert.cancelButtonTitle = "확인"
                        alert.show()
                    }
                case .authorized:
                    self?.presentPicker(source: source)
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
        
        let viewController = storyboard(.input).instantiateViewController(ofType: NameInputViewController.self)
        let navController = UINavigationController(rootViewController: viewController)
        var inputData = InputData()
        
        inputData.date = holiday?.date
        inputData.holiday = holiday?.title
        viewController.isRelationInput = false
        viewController.inputData = inputData
        viewController.entryRoute = .addHistoryAtHoliday
        viewController.setDatabaseManager(databaseManager)
        
        present(navController, animated: true, completion: nil)
    }
    
    @IBAction func touchUpSettingButton(_ sender: UIBarButtonItem) {
        let alert = BodabiAlertController(title: nil, message: nil, type: nil, style: .Alert)

        alert.addButton(title: "이름 수정", target: self, selector: #selector(showKeyboard))
        alert.addButton(title: "대표 이미지 변경", target: self, selector: #selector(showCameraActionSheet))
        alert.addButton(title: "삭제하기", target: self, selector: #selector(deleteHoliday))
        
        alert.cancelButtonTitle = "취소"
        alert.show()
    }
    
    // MARK: - @objc
    
    @objc func showKeyboard() {
        initTextField()
        if let textField = textField {
            textField.becomeFirstResponder()
        }
    }
    
    @objc func showCameraActionSheet() {
        let actionSheet = BodabiAlertController(type: .camera(SourceTypes: [.camera, .savedPhotosAlbum, .photoLibrary]), style: .ActionSheet)
        actionSheet.delegate = self
        actionSheet.show()
    }
    
    @objc func deleteHoliday() {
        let alert = BodabiAlertController(title: "정말 삭제하시겠습니까?", message: nil, type: nil, style: .Alert)
        
        alert.addButton(title: "확인") { [weak self] in
            if let holiday = self?.holiday {
                self?.databaseManager?.viewContext.delete(holiday)
            }
        
            let historyfetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: historyfetchRequest)
            
            do {
                try self?.databaseManager.viewContext.execute(deleteRequest)
            } catch {
                print(error.localizedDescription)
            }
            
            self?.navigationController?.popViewController(animated: true)
        }
        
        alert.cancelButtonTitle = "취소"
        alert.show()
    }
    
    @objc func popCurrentInputView(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension HolidayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let searchedHistories = searchedHistories, searchedHistories.count != 0 {
            isHolidayEmpty = false
            return searchedHistories.count
        } else if let histories = histories, histories.count != 0 {
            isHolidayEmpty = false
            return histories.count
        } else {
            isHolidayEmpty = true
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(isHolidayEmpty)
        if isHolidayEmpty {
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: "emptyHolidayCell", for: indexPath)
            return emptyCell
        } else {
            let cell = tableView.dequeue(ThanksFriendViewCell.self, for: indexPath)
            
            if let searchedHistories = searchedHistories {
                cell.bind(history: searchedHistories[indexPath.row])
            } else if let histories = histories {
                cell.bind(history: histories[indexPath.row])
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isHolidayEmpty {
            return tableView.rowHeight
        } else {
            return Const.cellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - UITableViewDelegate

extension HolidayViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ThanksFriendHeaderView.reuseIdentifier) as? ThanksFriendHeaderView else {
            return UIView()
        }

        let backgroundView = UIView(frame: header.bounds)
        backgroundView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        header.backgroundView = backgroundView
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
            
            guard let removedHistories = histories?.remove(at: indexPath.row) else { return }
            
            databaseManager.viewContext.delete(removedHistories)
            
            do {
                try databaseManager?.viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
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
    func didBeginEditing(_ searchBar: UISearchBar) {
        heightConstraint.constant = Const.minimumImageHeight
        informationView.incomeLabel.alpha = 0
        informationView.incomeIcon.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func didTapSortButton(_ headerView: ThanksFriendHeaderView) {
        let alert = BodabiAlertController(title: "정렬할 방법을 선택해주세요", message: nil, type: nil, style: .Alert)
        guard let histories = histories else { return }

        alert.addButton(title: "이름순") { [weak self] in
            self?.histories = histories.sorted { (a, b) in
                a.friend?.name ?? "" < b.friend?.name ?? ""
            }
        }

        alert.addButton(title: "금액순") { [weak self] in
            self?.histories = histories.sorted { (a, b) in
                a.item?.localizedStandardCompare(b.item ?? "") == .orderedAscending
            }
        }
        
        alert.cancelButtonTitle = "취소"
        alert.show()
    }
    
    func searchBar(_ searchBar: UISearchBar, searchBarTextDidChange searchText: String) {
        guard searchText != "" else {
            searchedHistories = nil
            return
        }
        
        let histories = self.histories?.filter {
            $0.friend?.name?.contains(search: searchText) ?? false
        }

        searchedHistories = histories
    }
    
    func didTapCancelButton(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchedHistories = nil
        heightConstraint.constant = Const.maximumImageHeight
        informationView.incomeIcon.alpha = 1.0
        informationView.incomeLabel.alpha = 1.0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
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
        informationView.blurView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
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

// MARK: - UITextFieldDelegate

extension HolidayViewController: UITextFieldDelegate {
    
    
    
    private func isUniqueName(with name: String) -> Bool {
        var isUnique: Bool = true
        let request: NSFetchRequest<Holiday> = Holiday.fetchRequest()
        
        if let fetchResult = try? databaseManager.viewContext.fetch(request) {
            fetchResult.forEach {
                if $0.title == name {
                    isUnique = false
                    return
                }
            }
        }
        
        return isUnique
    }
    
    private func updateHolidayName(to newName: String) {
        if newName != "", isUniqueName(with: newName) {
            navigationItem.title = newName
            holiday?.title = newName
            
            let updateRequest = NSBatchUpdateRequest(entityName: "History")
            
            updateRequest.propertiesToUpdate = ["holiday": newName]
            updateRequest.resultType = .updatedObjectsCountResultType
            
            do {
                try databaseManager.viewContext.execute(updateRequest)
                try databaseManager.viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        } else {
            let alert = BodabiAlertController(title: "주의", message: "중복된 이름입니다. 이름을 다시 입력해주세요.", type: nil, style: .Alert)
            
            alert.cancelButtonTitle = "확인"
            alert.show()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let newHolidayName = textField.text else { return true }
        updateHolidayName(to: newHolidayName)
        view.endEditing(true)
        return true
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

// MARK: - Keyboard

extension HolidayViewController {
    @objc func keyboardWillChange(_ notification: Foundation.Notification) {
        animateKeyboard(notification)
        adjustKeyboardDismisTapGesture(notification)
    }
    
    @objc func tapBackground(_ sender: UITapGestureRecognizer?) {
        if let textField = textField {
            textField.resignFirstResponder()
        }
    }
    
    private func adjustKeyboardDismisTapGesture(_ notification: Foundation.Notification) {
        if notification.name == UIWindow.keyboardDidHideNotification {
            guard let gesture = keyboardDismissGesture else { return }
            guard let textField = textField else { return }
            textField.removeFromSuperview()
            view.removeGestureRecognizer(gesture)
            keyboardDismissGesture = nil
        } else if notification.name == UIWindow.keyboardWillShowNotification {
            if keyboardDismissGesture != nil { return }
            let gesture = UITapGestureRecognizer(target: self, action: #selector(tapBackground(_:)))
            keyboardDismissGesture = gesture
            view.addGestureRecognizer(gesture)
        }
    }
    
    private func animateKeyboard(_ notification: Foundation.Notification) {
        guard let textField = textField else { return }
        if notification.name == UIWindow.keyboardWillChangeFrameNotification ||
            notification.name == UIWindow.keyboardWillShowNotification {
            let userInfo: NSDictionary = notification.userInfo! as NSDictionary
            let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            textField.frame.origin.y = view.frame.height - keyboardHeight - textField.frame.height
            
            UIView.animate(withDuration: 1.0) {
                self.view.layoutIfNeeded()
            }
        } else {
            textField.frame.origin.y = view.frame.height
            textField.text = ""
            textField.placeholder = navigationItem.title
            
            UIView.animate(withDuration: 1.0) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - Cell Protocol

protocol HolidayCellProtocol {
    func bind(history: History)
}
