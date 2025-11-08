//
//  AddReminderView.swift
//  ReMindApp
//

import SwiftUI
import SwiftData

struct AddReminderScreen: View {
    // MARK: - プロパティ
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(NotificationStore.self) private var notificationStore
    
    @State private var newReminderText = ""
    @State private var newReminderNotification = true
    @State private var attemptedSubmit = false
    
    // MARK: - AddView
    var body: some View {
        NavigationView {
            Form {
                ValidationSummaryView(errorMessages: addFormErrors)
                ReminderFormView(text: $newReminderText, isNotificationEnabled: $newReminderNotification)
                Button("追加") {
                    attemptedSubmit = true
                    guard addFormErrors.isEmpty else { return }
                    addProduct()
                    dismiss()
                }
                .disabled(newReminderText.isEmptyOrWhiteSpace || newReminderText.isOver200Characters)
            }
            .navigationTitle("新規追加")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
            .notificationErrorAlert()
        }
        
    }
    
    // MARK: - メソッド
    // TODO: メソッドを分離？（202511081709_13）
    func addProduct() {
        let newReminder = ReminderItem(text: newReminderText, isNotificationEnable: newReminderNotification, createdAt: Date.now)
        modelContext.insert(newReminder)
    }
    
    private var addFormErrors: [ReminderFormError] {
        var result: [ReminderFormError] = []
        if newReminderText.isOver200Characters { result.append(.overChar) }
        if attemptedSubmit && newReminderText.isEmptyOrWhiteSpace { result.append(.empty) }
        return result
    }
    
}

// MARK: - プレビュー
#Preview {
    AddReminderScreen()
        .modelContainer(for: [ReminderItem.self])
        .environment(NotificationStore())
}
