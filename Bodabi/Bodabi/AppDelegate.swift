//
//  AppDelegate.swift
//  Bodabi
//
//  Created by 이혜진 on 2019. 1. 24..
//  Copyright © 2019년 LeeHyeJin. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let coreDataManager = CoreDataManager(modelName: "Bodabi")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        setUserDefaults()
        coreDataManager.load()
        CloudManager.setCoreDataManager(manager: coreDataManager)
        
        registerForNotifications(application: application)
        updateDeliveredNotification()
        
        CloudManager.createCustomZone()
        CloudManager.subscribeToChanges()
        

        
        let tabBarController = window?.rootViewController
        for navigationController in tabBarController?.children ?? [] {
            let viewController = navigationController.children.first as? CoreDataManagerClient
            viewController?.setCoreDataManager(coreDataManager)
        }
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        renumberBadgesOfPendingNotifications()
        saveContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        CloudManager.pull { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        updateDeliveredNotification()
        resetApplicationIconBadge()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Received notification")
        
        guard let userInfo = userInfo as? [String: NSObject] else { return }
        guard let _ :CKDatabaseNotification = CKNotification(fromRemoteNotificationDictionary: userInfo) as? CKDatabaseNotification else { return
}
        
        CloudManager.pull {
            error in
            if let error = error {
                print(error.localizedDescription)
            }
            completionHandler(.newData)
        }
    }
    
//    func requestAutorizationRemoteNotification(application: UIApplication) {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
//            granted, error in
//            if let error = error {
//                print(error.localizedDescription)
//            } else {
//                if granted {
//                    DispatchQueue.main.async {
//                        application.registerForRemoteNotifications()
//                        application.delegate = self
//                    }
//                }
//            }
//        }
//    }
    
    // MARK: - User Defaults setting
    
    private func setUserDefaults() {
        let launchedBefore = UserDefaults.standard.bool(forKey: DefaultsKey.launchedBefore)
        
        if !launchedBefore  {
            UserDefaults.standard.set(true, forKey: DefaultsKey.launchedBefore)
            UserDefaults.standard.set(false, forKey: DefaultsKey.askedAuthorizeNotification)
            UserDefaults.standard.set(["+", "결혼", "생일", "돌잔치", "장례", "출산", "개업"], forKey: DefaultsKey.defaultHoliday)
            UserDefaults.standard.set(["+", "나", "아내", "어머니", "아버지", "아들", "딸"], forKey: DefaultsKey.defaultRelation)
            UserDefaults.standard.set(9, forKey: DefaultsKey.defaultAlarmHour)
            UserDefaults.standard.set(0, forKey: DefaultsKey.defaultAlarmMinutes)
            UserDefaults.standard.set(1, forKey: DefaultsKey.defaultAlarmDday)
            UserDefaults.standard.set(0, forKey: DefaultsKey.favoriteFirstAlarmDday)
            UserDefaults.standard.set(7, forKey: DefaultsKey.favoriteSecondAlarmDday)
        }
    }

    // MARK: - Method

    private func saveContext () {
        let context = coreDataManager.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func registerForNotifications(application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(
        options: [.badge, .sound, .alert]) {
            [weak center, weak self] granted, _ in
            guard granted, let center = center, let `self` = self
                else { return }
            if granted {
                center.delegate = self
            }
        }
    }
    
    private func resetApplicationIconBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

// MARK: - Handling Notifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
        
        updateDeliveredNotification()
        renumberBadgesOfPendingNotifications()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        updateDeliveredNotification()
    }
    
    func updateDeliveredNotification() {
        let predicate = NSPredicate(format: "date < %@", NSDate())
        let anotherPredicate = NSPredicate(format: "isRead = %@", NSNumber(value: false))
        let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicate, anotherPredicate])
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        
        coreDataManager.fetch(type: Notification.self, predicate: andPredicate, sortDescriptor: sortDescriptor) { result in
            switch result {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(notifications):
                notifications.forEach {
                    self.coreDataManager.updateNotification(object: $0, isHandled: true)  {
                        switch $0 {
                        case let .failure(error):
                            print(error.localizedDescription)
                        case .success:
                            break
                        }
                    }
                }
            }
        }
    }
    
    func renumberBadgesOfPendingNotifications() {
        let center = UNUserNotificationCenter.current()

        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            var pendingNotifications: [UNNotificationRequest] = []
            for request in requests {
                pendingNotifications.append(request)
                }
            pendingNotifications.sort(by: { (request, anotherRequest) -> Bool in
                if let date = request.content.userInfo["date"] as? Date,
                    let anotherDate = anotherRequest.content.userInfo["date"] as? Date {
                    return date < anotherDate
                } else {
                    return true
                }
            })
            var badgeNumber: Int = 1
            
            for notification in pendingNotifications {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.identifier])
                let content = UNMutableNotificationContent()
                
                content.title = notification.content.title
                content.body = notification.content.body
                content.sound = notification.content.sound
                content.badge = badgeNumber as NSNumber
                badgeNumber += 1
                
                let request = UNNotificationRequest(identifier: notification.identifier,
                                                    content: content,
                                                    trigger: notification.trigger)
                center.add(request, withCompletionHandler: nil)
            }
        }
    }
}
