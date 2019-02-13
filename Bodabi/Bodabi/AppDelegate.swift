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
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        
        if !launchedBefore  {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            UserDefaults.standard.set(["+", "결혼", "생일", "돌잔치", "장례", "출산", "개업"], forKey: "defaultHoliday")
        }
        
        databaseManager.load()
        registerForLocalNotifications(application: application)
        
        let tabBarController = window?.rootViewController
        for navigationController in tabBarController?.children ?? [] {
            let viewController = navigationController.children.first as? DatabaseManagerClient
            viewController?.setDatabaseManager(databaseManager)
        }
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        saveContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = databaseManager.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Request Notification Authorization
    
    func registerForLocalNotifications(application: UIApplication) {
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
}

// MARK: - Handling Notifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
        
        let content = notification.request.content
        guard let notificationID = content.userInfo["id"] as? String else { return }

        let request: NSFetchRequest<Notification> = Notification.fetchRequest()
        let predicate: NSPredicate = NSPredicate(format: "id = %@", notificationID)
        request.predicate = predicate
        
        if let result = try? databaseManager.viewContext.fetch(request) {
            let notification = result.first
            notification?.isHandled = true
            do {
                try databaseManager.viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
        renumberBadgesOfPendingNotifications()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        let content = response.notification.request.content
        guard let notificationID = content.userInfo["id"] as? String else { return }
        
        let request: NSFetchRequest<Notification> = Notification.fetchRequest()
        let predicate: NSPredicate = NSPredicate(format: "id = %@", notificationID)
        request.predicate = predicate
        
        if let result = try? databaseManager.viewContext.fetch(request) {
            let notification = result.first
            notification?.isHandled = true
            do {
                try databaseManager.viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
        renumberBadgesOfPendingNotifications()
    }
    
    func renumberBadgesOfPendingNotifications() {
        let center = UNUserNotificationCenter.current()
        var sortedNotifications: [UNNotificationRequest]?
        center.getPendingNotificationRequests { (pendingNotifications) in
            sortedNotifications = pendingNotifications.sorted(by: { ($0.trigger as! UNCalendarNotificationTrigger).nextTriggerDate()! < ($1.trigger as! UNCalendarNotificationTrigger).nextTriggerDate()! })
        }

        center.removeAllPendingNotificationRequests()
        var badgeNumber: Int = 1
        
        guard let notifications = sortedNotifications else { return }
        for notification in notifications {
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

