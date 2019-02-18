//
//  NotificationCreatable.swift
//  Bodabi
//
//  Created by jaehyeon lee on 12/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationSchedular: NSObject {
    
    static func create(notification: Notification, hour: Int? = nil, minute: Int? = nil) {
        
        // Prepare properties for register notification
        guard let event = notification.event else { return }
        guard let notificationID = notification.id else { return }
        guard let name = event.friend?.name else { return }
        
        let notificationString: String?
        if notification.difference == 0 {
            notificationString = "오늘은 \(name)님의 \(event.title ?? "")입니다."
        } else if notification.difference == 1 {
            notificationString = "내일은 \(name)님의 \(event.title ?? "")입니다."
        } else {
            notificationString = "(name)님의 \(event.title?.addSubjectSuffix() ?? "") \(notification.difference)일 남았습니다"
        }
        let content = UNMutableNotificationContent()
        content.title = "\(name)님의 경조사를 알려드립니다"
        content.body = notificationString! + "\n" + "\(name)님께 감사한 마음을 표현해보세요"
        content.sound = UNNotificationSound.default
        content.userInfo = ["id": notificationID]
        content.badge = 1
        
        // Make Trigger
        let calendar = Calendar.current
        var notificationDateComponents = calendar.dateComponents(
            [.era, .year, .month, .day], from: notification.date ?? Date())
        notificationDateComponents.setValue(hour, for: .hour)
        notificationDateComponents.setValue(minute, for: .minute)
        content.userInfo["date"] = notification.date
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDateComponents, repeats: false)

        // Make Request
        let request = UNNotificationRequest(identifier: notificationID,
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
    }
    
    static func delete(notification: Notification) {
        guard let notificationID = notification.id else { return }
        let identifiers = [notificationID]
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: identifiers)
    }
    
    static func deleteAllNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
