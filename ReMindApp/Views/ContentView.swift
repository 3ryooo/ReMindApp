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
    
    @AppStorage("firstStart") var firstStart  = true
    
    let selectedFrequency = UserDefaults.standard.integer(forKey: "frequencyKey")
    

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
    

    
    
    var body: some View {
        NavigationStack {
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
            .onAppear {
                print("開始")
                if firstStart {
                    print("設定変更")
                    UserDefaults.standard.set(24, forKey: "frequencyKey")
                    UserDefaults.standard.set(Date.now, forKey: "baseTime")
                    UserDefaults.standard.set(false, forKey: "isNotificationEnabled")
                    firstStart = false
                }
            }
        }
    }
    
    func deleteItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
    

    func debugFunc() {
        addSampleReminder()
    }
    
    func addSampleReminder() {
        
        do {
            try modelContext.delete(model: ReminderItem.self)
            print("モデル削除成功")
        } catch {
            print("モデル削除失敗")
        }
        
        modelContext.insert(ReminderItem(text: "未来を予測する最善の方法は、それを発明することだ。", isNotificationEnable: false, createdAt: Date(timeIntervalSinceNow: -432000)))
        modelContext.insert(ReminderItem(text: "千里の道も一歩から。", isNotificationEnable: true, createdAt: Date(timeIntervalSinceNow: 129600)))
        modelContext.insert(ReminderItem(text: "成功とは、情熱を失わずに失敗を重ねることである。", isNotificationEnable: true, createdAt: Date(timeIntervalSinceNow: -587321)))
        modelContext.insert(ReminderItem(text: "人生は自転車のようなものだ。倒れないようにするには走り続けなければならない。", isNotificationEnable: false, createdAt: Date(timeIntervalSinceNow: 345600)))
        modelContext.insert(ReminderItem(text: "困難の中に機会がある。", isNotificationEnable: true, createdAt: Date(timeIntervalSinceNow: 86400)))
        modelContext.insert(ReminderItem(text: "夢見ることができれば、それは実現できる。", isNotificationEnable: false, createdAt: Date(timeIntervalSinceNow: -259200)))
        modelContext.insert(ReminderItem(text: "唯一の真の知恵は、自分が何も知らないということを知ることにある。", isNotificationEnable: true, createdAt: Date(timeIntervalSinceNow: 518400)))
        modelContext.insert(ReminderItem(text: "行動はすべての成功の基本的な鍵である。", isNotificationEnable: false, createdAt: Date(timeIntervalSinceNow: -172800)))
        modelContext.insert(ReminderItem(text: "学び続ける限り、人は老いない。", isNotificationEnable: true, createdAt: Date(timeIntervalSinceNow: -302400)))
        modelContext.insert(ReminderItem(text: "幸福は目的地ではない。旅の仕方だ。", isNotificationEnable: true, createdAt: Date(timeIntervalSinceNow: 216000)))
        
    }
    
    
    
}

#Preview {
    ContentView()
}
