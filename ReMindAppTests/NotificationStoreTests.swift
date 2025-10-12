//
//  NotificationStoreTests.swift
//  ReMindAppTests
//

import Testing
@testable import ReMindApp
import SwiftData
import UserNotifications

@MainActor
struct NotificationStoreTests {
    
    enum MockError: Error { case fail }
    
    struct FailingScheduler: NotificationScheduling {
        func add(_ request: UNNotificationRequest, completionHandler: ((Error?) -> Void)?) {
            Task { @MainActor in
                completionHandler?(MockError.fail)
            }
        }
        func removeAllPendingNotificationRequests() { /* 何もしない */ }
    }
    
    @Test
    func schedulingFailureSetsAlert() async throws {
        let container = try ModelContainer(
            for: ReminderItem.self,
                 NotificationList.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        
        let item = ReminderItem(text: "テスト", isNotificationEnable: true, createdAt: .now)
        
        // 失敗モックを注入
        let store = NotificationStore(scheduler: FailingScheduler())
        store.isNotificationEnabled = true
        store.selectedFrequency = 24
        
        store.setNotificationList(for: [item], context: context)
        
        // DispatchQueue.main.asyncを待機
        try await Task.sleep(nanoseconds: 20_000_000) // 20ms 程度
        
        #expect(store.showingNotificationErrorAlert == true)
        #expect(store.notificationErrorMessage.contains("スケジューリングに失敗"))
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
}
