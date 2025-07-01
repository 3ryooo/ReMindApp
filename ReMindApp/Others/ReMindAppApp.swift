//
//  ReMindAppApp.swift
//  ReMindApp
//

import SwiftUI
import SwiftData

@main
struct ReMindAppApp: App {
    
    @State private var reminderStore = ReminderStore()
    @State private var notificationStore = NotificationStore()
    
    var body: some Scene {
        WindowGroup {
            MainScreen()
                .modelContainer(for: ReminderItem.self)
                .environment(reminderStore)
                .environment(notificationStore)
        }
    }
}
