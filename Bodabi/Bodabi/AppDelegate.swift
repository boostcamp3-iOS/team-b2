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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let databaseManager = DatabaseManager(modelName: "Bodabi")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        setUserDefaults()
        databaseManager.load()
        updateDeliveredNotification()
        
        let tabBarController = window?.rootViewController
        for navigationController in tabBarController?.children ?? [] {
            let viewController = navigationController.children.first as? DatabaseManagerClient
            viewController?.setDatabaseManager(databaseManager)
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
        updateDeliveredNotification()
        resetApplicationIconBadge()
    }
    
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
        let context = databaseManager.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func registerForLocalNotifications(application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(
        options: [.badge, .sound, .alert]) {
            [weak center, weak self] granted, _ in
            guard granted, let center = center, let `self` = self
                else { return }
            if granted {
                print("delegate")
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
    
    func updateDeliveredNotification() {
        let predicate = NSPredicate(format: "date > %@", NSDate())
        let anotherPredicate = NSPredicate(format: "isRead = %@", NSNumber(value: false))
        let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicate, anotherPredicate])
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        
        databaseManager.fetch(type: Notification.self, predicate: andPredicate, sortDescriptor: sortDescriptor) { results in
            for notification in results {
                self.databaseManager.updateNotification(object: notification, isHandled: true)
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

