//
//  ReminderStoreTests.swift
//  ReMindAppTests
//

import Testing
import Foundation
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
    func testIndexSetDeletion() async throws {
        
        // テスト用のリマインダーアイテムを作成
        let item1 = ReminderItem(text: "タスク1", isNotificationEnable: true, createdAt: Date().addingTimeInterval(-300))
        let item2 = ReminderItem(text: "タスク2", isNotificationEnable: false, createdAt: Date().addingTimeInterval(-200))
        let item3 = ReminderItem(text: "タスク3", isNotificationEnable: true, createdAt: Date().addingTimeInterval(-100))
        let item4 = ReminderItem(text: "タスク4", isNotificationEnable: false, createdAt: Date())
        
        var testItems = [item1, item2, item3, item4]
        
        // IndexSet.deleteItems()の実際のロジックをシミュレート
        // インデックス1と3を削除（item2とitem4）
        let indexesToDelete = IndexSet([1, 3])
        
        // 削除前の確認
        #expect(testItems.count == 4, "削除前は4つのアイテム")
        #expect(testItems[1].text == "タスク2", "インデックス1はタスク2")
        #expect(testItems[3].text == "タスク4", "インデックス3はタスク4")
        
        // IndexSetを降順でソートして削除（ビューの動作をシミュレート）
        let sortedIndices = indexesToDelete.sorted(by: >)
        for index in sortedIndices {
            testItems.remove(at: index)
        }
        
        // 削除後の確認
        #expect(testItems.count == 2, "削除後は2つのアイテム")
        #expect(testItems[0].text == "タスク1", "残ったアイテム1")
        #expect(testItems[1].text == "タスク3", "残ったアイテム2")
        
        // 削除されたアイテムが含まれていないことを確認
        let remainingTexts = testItems.map { $0.text }
        #expect(!remainingTexts.contains("タスク2"), "タスク2は削除されている")
        #expect(!remainingTexts.contains("タスク4"), "タスク4は削除されている")
        
    }

}
