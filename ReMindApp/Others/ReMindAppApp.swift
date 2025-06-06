//
//  ReMindAppApp.swift
//  ReMindApp
//

import SwiftUI
import SwiftData

@main
struct ReMindAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: ReminderItem.self)
        }
    }
}
