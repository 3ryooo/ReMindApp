//
//  ReminderStoreTests.swift
//  ReMindAppTests
//

import Testing
import Foundation
import SwiftData
@testable import ReMindApp

struct ReminderStoreTests {

    @Test("リマインダーソート機能のテスト")
    func testReminderStoreSorting() async throws {
        
        let reminderStore = ReminderStore()
        
        let now = Date()
        let item1 = ReminderItem(text: "タスクC", isNotificationEnable: true, createdAt: now.addingTimeInterval(-100))
        let item2 = ReminderItem(text: "タスクA", isNotificationEnable: false, createdAt: now.addingTimeInterval(-50))
        let item3 = ReminderItem(text: "タスクB", isNotificationEnable: true, createdAt: now)
        let testItems = [item1, item2, item3]
        
        
        reminderStore.sortOption = .name
        let sortedByName = reminderStore.getSortedItems(testItems)
        #expect(sortedByName[0].text == "タスクA", "名前順(1番目)")
        #expect(sortedByName[1].text == "タスクB", "名前順(2番目)")
        #expect(sortedByName[2].text == "タスクC", "名前順(3番目)")
        
        reminderStore.sortOption = .timestamp
        let sortedByTime = reminderStore.getSortedItems(testItems)
        #expect(sortedByTime[0].text == "タスクB", "新しい順(1番目)")
        #expect(sortedByTime[1].text == "タスクA", "新しい順(2番目)")
        #expect(sortedByTime[2].text == "タスクC", "新しい順(3番目)")
    }
    
    // TODO: （待ち）テストコードの削除
    @Test("IndexSetによる削除処理のテスト")
    @MainActor
    func testIndexSetDeletion() async throws {
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ReminderItem.self, configurations: config)
        let context = container.mainContext
        
        let item1 = ReminderItem(text: "タスク1", isNotificationEnable: true, createdAt: Date().addingTimeInterval(-300))
        let item2 = ReminderItem(text: "タスク2", isNotificationEnable: false, createdAt: Date().addingTimeInterval(-200))
        let item3 = ReminderItem(text: "タスク3", isNotificationEnable: true, createdAt: Date().addingTimeInterval(-100))
        let item4 = ReminderItem(text: "タスク4", isNotificationEnable: false, createdAt: Date())
        
        context.insert(item1)
        context.insert(item2)
        context.insert(item3)
        context.insert(item4)
        
        // 配列として準備（ソート順はcreatedAt昇順と仮定）
        let testItems = [item1, item2, item3, item4]
        
        let reminderStore = ReminderStore()
        
        // インデックス1と3を削除（item2とitem4）
        let indexesToDelete = IndexSet([1, 3])
        
        reminderStore.deleteItems(at: indexesToDelete, from: testItems, context: context)
        
        // コンテキストから削除されたか確認
        try context.save()
        
        let fetchDescriptor = FetchDescriptor<ReminderItem>()
        let remainingItems = try context.fetch(fetchDescriptor)
        
        // 削除後の確認
        #expect(remainingItems.count == 2, "削除後は2つのアイテム")
        
        let remainingTexts = remainingItems.map { $0.text }
        #expect(remainingTexts.contains("タスク1"), "タスク1は残る")
        #expect(remainingTexts.contains("タスク3"), "タスク3は残る")
        #expect(!remainingTexts.contains("タスク2"), "タスク2は削除される")
        #expect(!remainingTexts.contains("タスク4"), "タスク4は削除される")
    }

}
