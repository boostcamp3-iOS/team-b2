//
//  NotificationCreatable.swift
//  Bodabi
//
//  Created by jaehyeon lee on 12/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit
import UserNotifications

enum NotificationType {
    case normal
    case favorite
    
    var dateIntervals: [Int] {
        switch self {
        case .normal:
            return [1]
        case .favorite:
            return [0, 1, 7]
        }
    }
}

class NotificationSchedular: NSObject {
    static func createNotification(notification: Notification, notificationType: NotificationType, hour: Int? = nil, minute: Int? = nil) {
        
        // Prepare properties for register notification
        guard let event = notification.event else { return }
        guard let notificationID = notification.id else { return }
        guard let name = event.friend?.name else { return }

        let dateIntervals: [Int] = notificationType.dateIntervals
        let notificationString: [Int: String] = [
            0: "오늘은 \(name)님의 \(event.title ?? "")입니다.",
            1: "내일은 \(name)님의 \(event.title ?? "")입니다.",
            7: "\(name)님의 \(event.title ?? "")이 일주일 남았습니다."]
        
        
        for interval in dateIntervals {
            let content = UNMutableNotificationContent()
            content.title = "\(name)님의 경조사를 알려드립니다"
            content.body = notificationString[interval] ?? "" + "\(name)님께 감사한 마음을 표현해보세요"
            content.sound = UNNotificationSound.default
            content.userInfo = ["id": notificationID]
            content.badge = 1
            
            // Make Trigger
            let calendar = Calendar.current
            var notificationDateComponents = calendar.dateComponents(
                [.era, .year, .month, .day], from: notification.date ?? Date())
            notificationDateComponents.setValue(hour, for: .hour)
            notificationDateComponents.setValue(minute, for: .minute)
            
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
    }
}
