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
    
    // TODO: （転記済）ValidationSummaryViewをよりわかりやすく表示する(20251017_152953)
    // MARK: - EditView
    var body: some View {
        NavigationView {
            Form {
                ValidationSummaryView(errorMessages: editFormErrors)
                ReminderFormView(text: $reminderItem.text, itemNotificationEnabled: $reminderItem.itemNotificationEnabled)
            }
            .navigationTitle("編集")
        }
        .notificationErrorAlert()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 2) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                        Text("戻る")
                    }
                }
                .disabled(!editFormErrors.isEmpty)
            }
        }
        
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
        .modelContainer(for: [ReminderItem.self])
        .environment(NotificationStore())
}
