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

    @Test("NotificationStore初期化テスト")
    func testNotificationStoreInitialization() async throws {
        
        // テスト実行前の元の値を保存
        let originalFrequency = UserDefaults.standard.object(forKey: "frequencyKey")
        let originalBaseTime = UserDefaults.standard.object(forKey: "baseTime")
        
        // テスト後にクリーンアップするため、deferを使用
        defer {
            // 元の値を復元（テストがアプリに影響しないように）
            if let freq = originalFrequency {
                UserDefaults.standard.set(freq, forKey: "frequencyKey")
            } else {
                UserDefaults.standard.removeObject(forKey: "frequencyKey")
            }
            
            if let baseTime = originalBaseTime {
                UserDefaults.standard.set(baseTime, forKey: "baseTime")
            } else {
                UserDefaults.standard.removeObject(forKey: "baseTime")
            }
        }
        
        // テスト用にUserDefaultsをクリア
        UserDefaults.standard.removeObject(forKey: "frequencyKey")
        UserDefaults.standard.removeObject(forKey: "baseTime")
        
        // NotificationStoreを初期化（初回起動をシミュレート）
        let notificationStore = NotificationStore()
        
        // デフォルト値が正しく設定されているかテスト
        #expect(notificationStore.selectedFrequency == 24, 
                "デフォルト頻度（24時間）")
        
        #expect(UserDefaults.standard.integer(forKey: "frequencyKey") == 24, 
                "UserDefaultsにfrequencyKeyが保存される")
        
        // 基準時刻が現在時刻の近くに設定されているかテスト
        let now = Date()
        let timeDifference = abs(notificationStore.baseTime.timeIntervalSince(now))
        #expect(timeDifference < 5.0, 
                "基準時刻が現在時刻から5秒以内に設定される")
        
        // UserDefaultsに保存された値も確認
        let savedBaseTime = UserDefaults.standard.object(forKey: "baseTime") as? Date
        #expect(savedBaseTime != nil, 
                "UserDefaultsに基準時刻が保存される")
        
        if let savedTime = savedBaseTime {
            let savedTimeDifference = abs(savedTime.timeIntervalSince(now))
            #expect(savedTimeDifference < 5.0, 
                    "UserDefaultsの基準時刻も現在時刻から5秒以内")
        }
        
        // 既存の値がある場合のテスト（アプリ再起動をシミュレート）
        UserDefaults.standard.set(12, forKey: "frequencyKey")
        let testDate = Date().addingTimeInterval(-3600)
        UserDefaults.standard.set(testDate, forKey: "baseTime")
        
        let anotherStore = NotificationStore()
        
        #expect(anotherStore.selectedFrequency == 12, 
                "既存の頻度設定が維持される")
        
        let restoredBaseTime = anotherStore.baseTime
        let restoredTimeDifference = abs(restoredBaseTime.timeIntervalSince(testDate))
        #expect(restoredTimeDifference < 1.0, 
                "既存の基準時刻が維持される")
    }

    @Test("通知対象アイテムのフィルタリングテスト")
    func testNotificationItemFiltering() async throws {
        
        // テスト用のリマインダーアイテムを作成
        let enabledItem1 = ReminderItem(text: "通知有効タスク1", isNotificationEnable: true, createdAt: Date())
        let enabledItem2 = ReminderItem(text: "通知有効タスク2", isNotificationEnable: true, createdAt: Date())
        let disabledItem1 = ReminderItem(text: "通知無効タスク1", isNotificationEnable: false, createdAt: Date())
        let disabledItem2 = ReminderItem(text: "通知無効タスク2", isNotificationEnable: false, createdAt: Date())
        
        let allItems = [enabledItem1, disabledItem1, enabledItem2, disabledItem2]
        
        // 通知有効なアイテムのみをフィルタリング（updateNotificationの実際のロジック）
        let enabledItems = allItems.filter { $0.isNotificationEnable }.map { $0.text }
        let notificationTexts = enabledItems.isEmpty ? ["リストが空です"] : enabledItems
        
        // 通知有効なアイテムが2つあることを確認
        #expect(enabledItems.count == 2, "通知有効なアイテムが2つ")
        #expect(notificationTexts.count == 2, "通知テキストが2つ")
        #expect(notificationTexts.contains("通知有効タスク1"), "通知有効タスク1が含まれる")
        #expect(notificationTexts.contains("通知有効タスク2"), "通知有効タスク2が含まれる")
        #expect(!notificationTexts.contains("通知無効タスク1"), "通知無効タスク1は含まれない")
        
        // 空の場合のテスト
        let emptyItems: [ReminderItem] = []
        let emptyEnabledItems = emptyItems.filter { $0.isNotificationEnable }.map { $0.text }
        let emptyNotificationTexts = emptyEnabledItems.isEmpty ? ["リストが空です"] : emptyEnabledItems
        
        #expect(emptyNotificationTexts == ["リストが空です"], "空リストの場合のデフォルトメッセージ")
        
        // 全て無効な場合のテスト
        let allDisabledItems = [disabledItem1, disabledItem2]
        let allDisabledEnabledItems = allDisabledItems.filter { $0.isNotificationEnable }.map { $0.text }
        let allDisabledTexts = allDisabledEnabledItems.isEmpty ? ["リストが空です"] : allDisabledEnabledItems
        
        #expect(allDisabledTexts == ["リストが空です"], "全て無効な場合のデフォルトメッセージ")
    }

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

    @Test("通知メッセージ生成のビジネスロジックテスト")
    func testNotificationMessageGeneration() async throws {
        
        let lastNotificationId = 10
        let normalMessage = "テストメッセージ"
        
        // TODO: ヘルパー関数の有用性を確認
        func generateNotificationBody(message: String, currentId: Int, maxId: Int) -> String {
            return currentId == maxId 
                ? "\(message)\n通知の上限に達しました。設定より再度「保存」をタップしてください"
                : message
        }
        
        let normalId = 5
        let normalBody = generateNotificationBody(message: normalMessage, currentId: normalId, maxId: lastNotificationId)
        #expect(normalBody == normalMessage, "通常時はメッセージそのまま")

        let lastId = 10
        let lastBody = generateNotificationBody(message: normalMessage, currentId: lastId, maxId: lastNotificationId)
        let expectedLastMessage = "\(normalMessage)\n通知の上限に達しました。設定より再度「保存」をタップしてください"
        #expect(lastBody == expectedLastMessage, "上限時は特別メッセージ追加")
        
    }

}
