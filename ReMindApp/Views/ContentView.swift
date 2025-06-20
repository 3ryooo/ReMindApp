//
//  ContentView.swift
//  ReMindApp
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ReminderItem]
    
    @State private var showingAddReminderSheet = false
    @State private var showingSettingSheet = false
    
    
    var body: some View {
        NavigationStack {
            Button("通知認証") {
                requestAuthorization()
            }
            Button("通知テスト") {
                schaduleNotification()
            }
            Button("デバッグ用") {
                schaduleNotification()
            }
            List {
                ForEach(items) { item in
                    NavigationLink(destination: EditReminderView(reminderItem: item)) {
                        Text(item.text)
                            .opacity(item.isNotificationEnable ? 1 : 0.2)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            
            .navigationTitle("Re:Mind")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    EditButton()
                    Button {
                        showingAddReminderSheet = true
                    } label: {
                        Label("リマインド追加", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSettingSheet = true
                    } label: {
                        Label("設定", systemImage: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingAddReminderSheet) {
                AddReminderView()
            }
            .sheet(isPresented: $showingSettingSheet) {
                SettingsView()
            }
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView {
                        Label("リストが空です", systemImage: "tray.fill")
                    } description: {
                        Text("右上の＋から新しく追加してください")
                    }
                }
            }
        }
    }
    
    func deleteItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
    
    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("許可")
            } else if let error = error {
                print("失敗：\(error.localizedDescription)")
            }
            
        }
    }
    
//    TODO:トリガーを変更する
    private func schaduleNotification() {
        
//        TODO:全てを削除して問題ないか、個別に削除をしたほうがいいか後日確認
        let lcNotification = UNUserNotificationCenter.current()
        lcNotification.removeAllPendingNotificationRequests()
        
        
        let baseTime = UserDefaults.standard.object(forKey: "baseTime") as? Date ?? Date()
        var textRange: Int {
            if items.count > 0 {
                return items.count
            } else {
                return 1
            }
        }
        
        var remindTexts: [String] = []
        
        
        if items.count > 0 {
            for i in items {
                remindTexts.append(i.text)
            }
        } else {
            remindTexts.append("リストが空です")
        }
        
        let randomNumber = Int.random(in: 0..<textRange)
        print(remindTexts)
        
        
        let content = UNMutableNotificationContent()
        content.title = "Re:Mind" // ランダムで作成？
        content.body = remindTexts[randomNumber]
        content.sound = .default
        
        let cal = Calendar(identifier: .gregorian)
        let baseTimeHour = cal.component(.hour, from: baseTime)
        let baseTimeMinute = cal.component(.minute, from: baseTime)
        
        var dateComponents = DateComponents()
        dateComponents.hour = baseTimeHour
        dateComponents.minute = baseTimeMinute
        
        
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("スケジューリング失敗：\(error.localizedDescription)")
            } else {
                print("スケジューリング成功")
            }
        }
    }
    
    
}

#Preview {
    ContentView()
}
