//
//  EditReminderView.swift
//  ReMindApp
//

import SwiftUI

struct EditReminderScreen: View {
    // MARK: - プロパティ
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var reminderItem: ReminderItem
    
    // MARK: - EditView
    var body: some View {
        NavigationView {
            Form {
                TextField("リマインドテキスト", text: $reminderItem.text, axis: .vertical)
                Toggle(isOn: $reminderItem.isNotificationEnable) {
                    Text("リマインド対象")
                }
            }
            .navigationTitle("編集")
        }
        
    }
}

// MARK: - プレビュー
#Preview {
    EditReminderScreen(reminderItem: ReminderItem(text: "aaa", isNotificationEnable: true, createdAt: Date.now))
        .modelContainer(for: ReminderItem.self)
}
