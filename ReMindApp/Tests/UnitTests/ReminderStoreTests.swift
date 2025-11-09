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

}
