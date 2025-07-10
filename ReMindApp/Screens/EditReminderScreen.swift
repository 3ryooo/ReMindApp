//
//  EditReminderView.swift
//  ReMindApp
//

import SwiftUI

struct EditReminderScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var reminderItem: ReminderItem
    
    var body: some View {
        NavigationView {
            Form {
                TextField("リマインドテキスト", text: $reminderItem.text)
                Toggle(isOn: $reminderItem.isNotificationEnable) {
                    Text("リマインド対象")
                }
                Button("追加") {
//                    addReminder()
                    dismiss()
                }
                .disabled(reminderItem.text.isEmpty ? true : false)
            }
            .navigationTitle("編集")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
        
    }
    
//    func addReminder() {
//        let newReminder = ReminderItem(text: newReminderText, isNotificationEnable: newReminderNotification)
//        modelContext.insert(newReminder)
//    }
}

#Preview {
    EditReminderScreen(reminderItem: ReminderItem(text: "aaa", isNotificationEnable: true, createdAt: Date.now))
        .modelContainer(for: ReminderItem.self)
}
