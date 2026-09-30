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
    @Query private var items: [ReminderItem]
    
    @State private var selection = Set<ReminderItem.ID>()
    @State private var editMode: EditMode = .inactive
    
    
    private var displayedItems: [ReminderItem] {
        return reminderStore.getSortedItems(items)
    }

    // MARK: - MainView
    var body: some View {
        
        @Bindable var reminderStore = reminderStore
        @Bindable var notificationStore = notificationStore
        
        NavigationStack {
            #if DEBUG
            Button("サンプル挿入") {
                debugFunc()
            }
            Button("登録済通知Print") {
                debugFunc2()
            }
            #endif
            List(displayedItems, id: \.id, selection: $selection) { item in
                NavigationLink(destination: EditReminderScreen(reminderItem: item)) {
                    Text(item.text)
                        .opacity(item.itemNotificationEnabled ? 1 : 0.2)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        if let index = items.firstIndex(where: { $0.id == item.id }) {
                            deleteItems(offsets: IndexSet(integer: index))
                        }
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                }
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
            .navigationTitle("Re:Mind")
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        reminderStore.showingAddSettingSheet = true
                    } label: {
                        Label("設定", systemImage: "gear")
                    }
                    EditButton()
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if editMode == .active && !selection.isEmpty {
                        Button("削除", role: .destructive) {
                            deleteSelectedItems()
                        }
                    } else {
                        Button {
                            reminderStore.showingAddReminderSheet = true
                        } label: {
                            Label("リマインド追加", systemImage: "plus")
                        }
                        Menu("並び順", systemImage: "arrow.up.arrow.down") {
                            Picker("並び順", selection:$reminderStore.sortOption) {
                                Text(SortOption.name.displayTitle).tag(SortOption.name)
                                Text(SortOption.timestamp.displayTitle).tag(SortOption.timestamp)
                            }
                        }
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .sheet(isPresented: $reminderStore.showingAddReminderSheet) {
                AddReminderScreen()
            }
            .fullScreenCover(isPresented: $reminderStore.showingAddSettingSheet) {
                NavigationStack {
                    SettingsScreen()
                }
            }
            .alert("通知設定エラー", isPresented: $notificationStore.showingNotificationErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(notificationStore.notificationErrorMessage)
            }
            
        }
    }
    
    // MARK: - メソッド
    func deleteItems(offsets: IndexSet) {
        reminderStore.deleteItems(at: offsets, from: items, context: modelContext)
    }
    
    private func deleteSelectedItems() {
        withAnimation {
            let indicesToDelete = items.enumerated().compactMap { index, item in
                selection.contains(item.id) ? index : nil
            }
            
            let indexSet = IndexSet(indicesToDelete)
            reminderStore.deleteItems(at: indexSet, from: items, context: modelContext)
            
            selection.removeAll()
            editMode = .inactive 
        }
    }

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
