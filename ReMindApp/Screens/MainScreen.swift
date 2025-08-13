//
//  MainView.swift
//  ReMindApp
//

import SwiftUI
import SwiftData

struct MainScreen: View {
    
    // MARK: - プロパティ
    @Environment(\.modelContext) private var modelContext
    @Environment(ReminderStore.self) private var reminderStore
    @Environment(NotificationStore.self) private var notificationStore
    @AppStorage("firstStart") var firstStart  = true
    @Query private var items: [ReminderItem]
    
    private var bindableReminderStore: Bindable<ReminderStore> {
        Bindable(reminderStore)
    }
    
    private var displayedItems: [ReminderItem] {
        return reminderStore.getSortedItems(items)
    }

    // MARK: - MainView
    var body: some View {
        NavigationStack {
            Button("デバッグ用") {
                debugFunc()
            }
            Button("デバッグ用2") {
                debugFunc2()
            }
            List {
                ForEach(displayedItems) { item in
                    NavigationLink(destination: EditReminderScreen(reminderItem: item)) {
                        Text(item.text)
                            .opacity(item.isNotificationEnable ? 1 : 0.2)
                    }
                }
                .onDelete(perform: deleteItems)
                
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
            .onAppear {
                if firstStart {
                    UserDefaults.standard.set(24, forKey: "frequencyKey")
                    UserDefaults.standard.set(0, forKey: "countForReviewRequest")
                    UserDefaults.standard.set(Date.now, forKey: "baseTime")
                    UserDefaults.standard.set(false, forKey: "isNotificationEnabled")
                    UserDefaults.standard.set(false, forKey: "isRandomTimeEnabled")
                    firstStart = false
                }
            }
            .navigationTitle("Re:Mind")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    EditButton()
                    Button {
                        reminderStore.showingAddReminderSheet = true
                    } label: {
                        Label("リマインド追加", systemImage: "plus")
                    }
                    Menu("並び順", systemImage: "arrow.up.arrow.down") {
                        Picker("並び順", selection: bindableReminderStore.sortOption) {
                            Text(SortOption.name.displayTitle).tag(SortOption.name)
                            Text(SortOption.timestamp.displayTitle).tag(SortOption.timestamp)
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        reminderStore.showingSettingSheet = true
                    } label: {
                        Label("設定", systemImage: "gear")
                    }
                }
            }
            .sheet(isPresented: bindableReminderStore.showingAddReminderSheet) {
                AddReminderScreen()
            }
            .sheet(isPresented: bindableReminderStore.showingSettingSheet) {
                SettingsScreen()
            }
            
        }
    }
    
    // MARK: - メソッド
    func deleteItems(offsets: IndexSet) {
        reminderStore.deleteItems(at: offsets, from: items, context: modelContext)
        
        // アイテム削除後に通知を更新
        notificationStore.updateNotification(context: modelContext)
    }
    
    // TODO: 検証後削除
    func debugFunc() {
        reminderStore.addSampleReminder(context: modelContext)
        
        
    }
    
    func debugFunc2() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            for request in requests {
                print("ID: \(request.identifier)")
                print("Title: \(request.content.title)")
                print("Body: \(request.content.body)")
                print("Trigger: \(String(describing: request.trigger))")
                print("------")
            }
        }
    }
    
}

// MARK: - プレビュー
#Preview {
    MainScreen()
        .environment(ReminderStore())
        .environment(NotificationStore())
}
