//
//  NotificationScheduling.swift
//  ReMindApp
//

import Foundation
import UserNotifications

protocol NotificationScheduling {
    func add(_ request: UNNotificationRequest, completionHandler: ((Error?) -> Void)?)
    func removeAllPendingNotificationRequests()
}

struct DefaultNotificationScheduler: NotificationScheduling {
    func add(_ request: UNNotificationRequest, completionHandler: ((Error?) -> Void)?) {
        UNUserNotificationCenter.current().add(request, withCompletionHandler: completionHandler)
    }
    func removeAllPendingNotificationRequests() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
