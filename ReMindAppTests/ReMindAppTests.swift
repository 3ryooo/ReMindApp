//
//  ReMindAppTests.swift
//  ReMindAppTests
//

import Testing
import Foundation
@testable import ReMindApp

struct ReMindAppTests {

    @Test("日本時間フォーマットの確認")
    func testDateConverterJapanTime() async throws {
        
        let dateConverter = DateConverter()
        
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.year = 2024
        components.month = 12
        components.day = 25
        components.hour = 15
        components.minute = 30
        components.second = 45
        components.timeZone = TimeZone(identifier: "UTC")
        
        guard let testDate = calendar.date(from: components) else {
            Issue.record("テスト用の日付を作成できませんでした")
            return
        }
        
        let result = dateConverter.japanTime(testDate)
        
        let expectedFormat = "2024/12/26 00:30:45"
        
        #expect(result == expectedFormat, 
                "日時が一致しません 正しい値: \(expectedFormat), 実際の値: \(result)")
    }

    @Test("空文字・空白文字のテスト")
    func testStringIsEmptyOrWhiteSpace() async throws {
        
        let emptyString = ""
        #expect(emptyString.isEmptyOrWhiteSpace == true, 
                "空文字→true")
        
        let whitespaceString = "   "
        #expect(whitespaceString.isEmptyOrWhiteSpace == true, 
                "空白→true")
        
        let validString = "テスト"
        #expect(validString.isEmptyOrWhiteSpace == false,
                "文字列→false")
    
        let stringWithSpaces = "  テスト  "
        #expect(stringWithSpaces.isEmptyOrWhiteSpace == false, 
                "文字列+空白→false")
    }

    @Test("リマインダーアイテムの作成テスト")
    func testReminderItemCreation() async throws {
        
        let testText = "テスト"
        let testNotificationEnabled = true
        let testDate = Date()
        
        let reminderItem = ReminderItem(
            text: testText,
            isNotificationEnable: testNotificationEnabled,
            createdAt: testDate
        )
        
        #expect(reminderItem.text == testText, 
                "テキスト設定")
        
        #expect(reminderItem.isNotificationEnable == testNotificationEnabled, 
                "通知有効化")
        
        #expect(reminderItem.createdAt == testDate, 
                "作成日時設定")
        
        #expect(reminderItem.id.uuidString.count == 36, 
                "UUID確認")
        
    }

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
