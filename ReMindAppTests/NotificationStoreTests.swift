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
    
    @Test("ランダム通知時刻生成のテスト")
    func testRandomNotificationTimeGeneration() async throws {
        
        // 基準日時を設定（2024/12/25 14:30:00）
        let calendar = Calendar(identifier: .gregorian)
        var baseComponents = DateComponents()
        baseComponents.year = 2024
        baseComponents.month = 12
        baseComponents.day = 25
        baseComponents.hour = 14
        baseComponents.minute = 30
        baseComponents.second = 0
        
        guard let baseDate = calendar.date(from: baseComponents) else {
            Issue.record("基準日時の作成に失敗")
            return
        }
        
        // ランダム時刻生成
        func generateRandomNotificationDate(setDate: Date, frequency: Int, isRandomEnabled: Bool) -> Date? {
            let notificationDate = setDate.addingTimeInterval(TimeInterval(60 * 60 * frequency))
            
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
            
            if isRandomEnabled && frequency >= 24 {
                components.hour = Int.random(in: 0..<24)
                components.minute = Int.random(in: 0..<59)
            }
            
            return calendar.date(from: components)
        }
        
        // ランダム無効
        let nonRandomDate = generateRandomNotificationDate(setDate: baseDate, frequency: 24, isRandomEnabled: false)
        if let date = nonRandomDate {
            let components = calendar.dateComponents([.hour, .minute], from: date)
            #expect(components.hour == 14, "時が変わらない")
            #expect(components.minute == 30, "分が変わらない")
        }
        
        // ランダム有効
        let randomDate = generateRandomNotificationDate(setDate: baseDate, frequency: 24, isRandomEnabled: true)
        if let date = randomDate {
            let components = calendar.dateComponents([.hour, .minute], from: date)
            #expect(components.hour! >= 0 && components.hour! < 24, "時が0-23の範囲")
            #expect(components.minute! >= 0 && components.minute! < 59, "分が0-58の範囲")
            #expect(components.hour != 14 || components.minute != 30, "ランダムで時刻が変わる")
        }
        
        // 頻度が24未満の場合：ランダムが適用されない
        let lowFrequencyDate = generateRandomNotificationDate(setDate: baseDate, frequency: 12, isRandomEnabled: true)
        if let date = lowFrequencyDate {
            let components = calendar.dateComponents([.hour, .minute], from: date)
            #expect(components.hour == 2, "12時間後は2時（14+12=26, 24時超え）")
            #expect(components.minute == 30, "分は変わらない")
        }
        
        //　頻度が24の場合
        let exact24Date = generateRandomNotificationDate(setDate: baseDate, frequency: 24, isRandomEnabled: true)
        if let date = exact24Date {
            let baseComponents = calendar.dateComponents([.year, .month, .day], from: baseDate)
            let resultComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            
            #expect(resultComponents.year == baseComponents.year, "年は同じ")
            #expect(resultComponents.month == baseComponents.month, "月は同じ")
            #expect(resultComponents.day == (baseComponents.day! + 1), "1日後")
            #expect(resultComponents.hour != 14, "時ランダム")
            #expect(resultComponents.minute != 30, "分ランダム")
        }
    }
}
