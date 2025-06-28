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
            ContentView()
                .modelContainer(for: ReminderItem.self)
                .environment(reminderStore)
                .environment(notificationStore)
        }
    }
}
