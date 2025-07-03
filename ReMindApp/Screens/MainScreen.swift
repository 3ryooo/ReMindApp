//
//  MainView.swift
//  ReMindApp
//

import SwiftUI
import SwiftData

enum SortOption {
    case name, timestamp
}

struct MainScreen: View {
    
    @Environment(ReminderStore.self) private var reminderStore
    @Environment(NotificationStore.self) private var notificationStore
    
    private var bindableReminderStore: Bindable<ReminderStore> {
        Bindable(reminderStore)
    }
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ReminderItem]
    
    @AppStorage("firstStart") var firstStart  = true
    
    private var displayedItems: [ReminderItem] {
        return reminderStore.getSortedItems(items)
    }

    var body: some View {
        NavigationStack {
            Button("デバッグ用") {
                debugFunc()
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
                            Text("名前順").tag(SortOption.name)
                            Text("新しい順").tag(SortOption.timestamp)
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
                    UserDefaults.standard.set(Date.now, forKey: "baseTime")
                    UserDefaults.standard.set(false, forKey: "isNotificationEnabled")
                    UserDefaults.standard.set(false, forKey: "isRandomTimeEnabled")
                    firstStart = false
                }
            }
        }
    }
    
    func deleteItems(offsets: IndexSet) {
        reminderStore.deleteItems(at: offsets, from: items, context: modelContext)
    }
    
    func debugFunc() {
        reminderStore.addSampleReminder(context: modelContext)
    }
    
}

#Preview {
    MainScreen()
        .environment(ReminderStore())
        .environment(NotificationStore())
}
