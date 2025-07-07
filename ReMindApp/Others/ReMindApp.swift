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
    
    var body: some Scene {
        WindowGroup {
            MainScreen()
                .modelContainer(for: ReminderItem.self)
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
    
//    TODO:タップ後の挙動を調整？
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

}
