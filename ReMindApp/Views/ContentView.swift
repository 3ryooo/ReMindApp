//
//  ContentView.swift
//  ReMindApp
//

import SwiftUI
import SwiftData

enum SortOption {
    case name, timestamp
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ReminderItem]
    
    @State private var showingAddReminderSheet = false
    @State private var showingSettingSheet = false
    
    @State private var sortOption: SortOption = .timestamp
    
    let selectedFrequency = UserDefaults.standard.integer(forKey: "frequencyKey")
    
//    テスト中のため数を少なめに設定
    let lastNotificationId = 1
    
    private var displayedItems: [ReminderItem] {
        var filtered = items
        
        switch sortOption {
        case .name:
            filtered.sort {$0.text < $1.text}
        case .timestamp:
            filtered.sort {$0.createdAt > $1.createdAt}
        }
        return filtered
    }
    
    private var notifiedItems: [ReminderItem] {
        var filterd = items
        
        filterd = filterd.filter { $0.isNotificationEnable == true }
        
        return filterd
    }
    
    
    var body: some View {
        NavigationStack {
            Button("通知認証") {
                requestAuthorization()
            }
            Button("通知テスト") {
                setNotificationList()
//                debugFunc()
            }
            Button("デバッグ用") {
                debugFunc()
            }
            List {
                ForEach(displayedItems) { item in
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
                    Menu("並び順", systemImage: "arrow.up.arrow.down") {
                        Picker("並び順", selection: $sortOption) {
                            Text("名前順").tag(SortOption.name)
                            Text("新しい順").tag(SortOption.timestamp)
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .topBarLeading) {
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
    
    func setNotificationList() {
        
//        トリガーは保存時のみ？→長期的なリマインドが毎回消えてしまう
        let lcNotification = UNUserNotificationCenter.current()
        lcNotification.removeAllPendingNotificationRequests()
        
        for i in 1...lastNotificationId {
            setNotification(i)
        }
        
        
    }
    
//    TODO:トリガーを変更する
    private func setNotification(_ id : Int) {
        
//        TODO:個別のリマインダーをON・OFFしたときにスケジュールを残したまま対象のアイテムを変更する方法
        var textRange: Int {
            if notifiedItems.count > 0 {
                return notifiedItems.count
            } else {
                return 1
            }
        }
        
        var remindTexts: [String] = []
        
        
        if notifiedItems.count > 0 {
            for i in notifiedItems {
                remindTexts.append(i.text)
            }
        } else {
            remindTexts.append("リストが空です")
        }
        
        let randomNumber = Int.random(in: 0..<textRange)
        
        
        let content = UNMutableNotificationContent()
        content.title = "Re:Mind" // ランダムで作成？
        content.body = remindTexts[randomNumber]
        
        if id == lastNotificationId {
            content.body = "\(remindTexts[randomNumber])\n通知の上限に達しました。設定より再度「保存」をタップしてください"
        }
        
        
        
        content.sound = .default
        
        let date = Date()
//        let newDate = Date(timeInterval: TimeInterval(60 * 60 * id), since: date)
        
//        テスト用
        let newDate = Date(timeInterval: TimeInterval(60 * id), since: date)
        
        
        let component = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: newDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("スケジューリング失敗：\(error.localizedDescription)")
            } else {
                print("スケジューリング成功\nid:\(id)\n通知予定：\(newDate)")
            }
        }
    }
    
    func debugFunc() {
    }
    
    
}

#Preview {
    ContentView()
}
