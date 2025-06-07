//
//  AddReminderView.swift
//  ReMindApp
//

import SwiftUI
import SwiftData

struct AddReminderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var newReminderText = ""
    @State private var newReminderNotification = true
    
    
    var body: some View {
        NavigationView {
            Form {
                TextField("リマインドテキスト", text: $newReminderText)
                Toggle(isOn: $newReminderNotification) {
                    Text("リマインド対象")
                }
                Button("追加") {
                    addProduct()
                    dismiss()
                }
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
    
    func addProduct() {
        let newReminder = ReminderItem(text: newReminderText, isNotificationEnable: newReminderNotification)
        modelContext.insert(newReminder)
    }
    
}

#Preview {
    AddReminderView()
}
