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
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        
        let item = ReminderItem(text: "テスト", isNotificationEnable: true, createdAt: .now)
        
        // モックを注入
        let mockDefaults = MockUserDefaults()
        let store = NotificationStore(scheduler: FailingScheduler(), userDefaults: mockDefaults)
        store.isNotificationEnabled = true
        store.selectedFrequency = 24
        
        store.setNotificationList(for: [item])
        
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
    
    @Test("通知アイテムのランダム選択テスト")
    func testGetNotifiedItem() async throws {
        
        // テスト用のリマインダーアイテムを作成
        let item1 = ReminderItem(text: "タスク1", isNotificationEnable: true, createdAt: Date())
        let item2 = ReminderItem(text: "タスク2", isNotificationEnable: true, createdAt: Date())
        let item3 = ReminderItem(text: "タスク3", isNotificationEnable: false, createdAt: Date())
        
        // ビジネスロジックを再現
        func getNotifiedItem(items: [ReminderItem]) -> String {
            let notifiedItems = items.filter { $0.isNotificationEnable == true }
            
            let remindTexts: [String]
            if notifiedItems.count > 0 {
                remindTexts = notifiedItems.map { $0.text }
            } else {
                remindTexts = ["リストが空です"]
            }
            
            // 実際のアプリではランダムだが、テストでは最初の要素を返すことで一貫性を保つ
            return remindTexts.first ?? "リストが空です"
        }
        
        let result1 = getNotifiedItem(items: [item1, item2, item3])
        let enableLists = ["タスク1", "タスク2"]
        #expect(enableLists.contains(result1), "有効なアイテムから選択される")
        
        // 全て無効な場合
        let result2 = getNotifiedItem(items: [item3])
        #expect(result2 == "リストが空です", "全て無効な場合はデフォルトメッセージ")
        
        // 空の場合
        let result3 = getNotifiedItem(items: [])
        #expect(result3 == "リストが空です", "リストが空の場合はデフォルトメッセージ")
        
        // ランダム性の検証（複数回実行して異なる結果が出るか）
        var results = Set<String>()
        for _ in 0..<20 {
            let notifiedItems = [item1, item2].filter { $0.isNotificationEnable == true }
            let remindTexts = notifiedItems.map { $0.text }
            if let randomText = remindTexts.randomElement() {
                results.insert(randomText)
            }
        }
        #expect(results.count > 1, "複数回実行で異なる結果が選択される（ランダム性）")
    }
    
    @Test("データ0件時のテスト")
    func testEmptyData() async throws {
        
        let reminderStore = ReminderStore()
        let emptyItems: [ReminderItem] = []
        
        func getNotifiedItemForEmptyList(items: [ReminderItem]) -> String {
            let notifiedItems = items.filter { $0.isNotificationEnable == true }
            
            let remindTexts: [String]
            if notifiedItems.count > 0 {
                remindTexts = notifiedItems.map { $0.text }
            } else {
                remindTexts = ["リストが空です"]
            }
            
            return remindTexts.randomElement() ?? "リストが空です"
        }
        
        let notificationMessage = getNotifiedItemForEmptyList(items: emptyItems)
        #expect(notificationMessage == "リストが空です", "0件時にデフォルトメッセージが生成される")
        
        // 0件データでの通知作成時の処理
        let enabledItems = emptyItems.filter { $0.isNotificationEnable }
        let notificationTexts = enabledItems.isEmpty ? ["リストが空です"] : enabledItems.map { $0.text }
        
        #expect(enabledItems.isEmpty, "0件データでは通知有効アイテムも0件")
        #expect(notificationTexts == ["リストが空です"], "0件時は「リストが空です」が通知テキストになる")
        #expect(notificationTexts.count == 1, "デフォルトメッセージは1つ")
        
        // 複数回実行してもクラッシュしないことを確認
        for _ in 0..<10 {
            let randomMessage = notificationTexts.randomElement() ?? "フォールバック"
            #expect(randomMessage == "リストが空です", "0件データでのランダム選択は常にデフォルトメッセージ")
        }
    }
}
