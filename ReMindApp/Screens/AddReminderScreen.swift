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
    
    @State private var newReminderText = ""
    @State private var newReminderNotification = true
    
    // MARK: - AddView
    var body: some View {
        NavigationView {
            Form {
                TextField("リマインドテキスト", text: $newReminderText, axis: .vertical)
                Toggle(isOn: $newReminderNotification) {
                    Text("リマインド対象")
                }
                Button("追加") {
                    addProduct()
                    dismiss()
                }
                .disabled(newReminderText.isEmptyOrWhiteSpace)
            }
            .navigationTitle("新規追加")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
        
    }
    
    // MARK: - メソッド
    func addProduct() {
        let newReminder = ReminderItem(text: newReminderText, isNotificationEnable: newReminderNotification, createdAt: Date.now)
        modelContext.insert(newReminder)
    }
    
}

// MARK: - プレビュー
#Preview {
    AddReminderScreen()
}
