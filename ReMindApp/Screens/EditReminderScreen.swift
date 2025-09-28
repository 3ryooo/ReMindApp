//
//  EditReminderView.swift
//  ReMindApp
//

import SwiftUI

struct EditReminderScreen: View {
    // MARK: - プロパティ
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(NotificationStore.self) private var notificationStore
    
    @Bindable var reminderItem: ReminderItem
    
    // MARK: - EditView
    var body: some View {
        NavigationView {
            Form {
                ReminderFormView(text: $reminderItem.text, isNotificationEnabled: $reminderItem.isNotificationEnable)
            }
            .onChange(of: reminderItem.text) { _, _ in
                notificationStore.updateNotification(context: modelContext)
            }
            .onChange(of: reminderItem.isNotificationEnable) { _, _ in
                notificationStore.updateNotification(context: modelContext)
            }
            .navigationTitle("編集")
        }
        .notificationErrorAlert()
        
    }
}

// MARK: - プレビュー
#Preview {
    EditReminderScreen(reminderItem: ReminderItem(text: "aaa", isNotificationEnable: true, createdAt: Date.now))
        .modelContainer(for: ReminderItem.self)
}
