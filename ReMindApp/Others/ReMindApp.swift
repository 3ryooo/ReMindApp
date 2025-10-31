//
//  ReMindAppApp.swift
//  ReMindApp
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct ReMindApp: App {
    
    @State private var reminderStore = ReminderStore()
    @State private var notificationStore = NotificationStore()
    init() {
        UserDefaults.standard.register(defaults: [
            "frequencyKey": 24,
            "countForReviewRequest": 0,
            "baseTime": Date.now,
            "isNotificationEnabled": false,
            "isRandomTimeEnabled": false
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            MainScreen()
                .modelContainer(for: [ReminderItem.self, NotificationList.self])
                .environment(reminderStore)
                .environment(notificationStore)
                .onAppear {
                    UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
                }
        }
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    private override init() {
        super.init()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

}
