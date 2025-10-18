//
//  EditReminderScreen.swift
//  ReMindApp
//

import SwiftUI

struct EditReminderScreen: View {
    // MARK: - プロパティ
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(NotificationStore.self) private var notificationStore
    
    @Bindable var reminderItem: ReminderItem
    
    // TODO: （転記済）Validateを無視して保存できないようにする→再度挙動確認(20251017_153247)
    // TODO: （転記済）ValidationSummaryViewをよりわかりやすく表示する(20251017_152953)
    
    // MARK: - EditView
    var body: some View {
        NavigationView {
            Form {
                ValidationSummaryView(errorMessages: editFormErrors)
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
    
    private var editFormErrors: [ReminderFormError] {
        var result: [ReminderFormError] = []
        if reminderItem.text.isOver200Characters { result.append(.overChar) }
        if reminderItem.text.isEmptyOrWhiteSpace { result.append(.empty) }
        return result
    }
}

// MARK: - プレビュー
#Preview {
    EditReminderScreen(reminderItem: ReminderItem(text: "aaa", isNotificationEnable: true, createdAt: Date.now))
        .modelContainer(for: [ReminderItem.self, NotificationList.self])
        .environment(NotificationStore())
}
