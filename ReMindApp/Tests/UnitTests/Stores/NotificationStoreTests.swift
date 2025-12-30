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
    
    // MARK: - 共通データ（モック等）
    
    // MARK: - requestAuthorization
    
    // MARK: - saveSettings
    
    @Test("saveSettingsの保存テスト")
    func testUserDefaultsSavedCorrectlyWithSaveSettings() async throws {
        
        let mockDefaults = MockUserDefaults()
        let store = NotificationStore(userDefaults: mockDefaults)
        
        // 初期値の保存
        store.appNotificationEnabled = true
        store.isRandomTimeEnabled = false
        store.selectedFrequency = 24
        let testDate = Date()
        store.baseTime = testDate
        
        store.saveSettings()
        
        // 保存された値を検証
        #expect(mockDefaults.bool(forKey: AppConstants.UserDefaultsKeys.appNotificationEnabled) == true,
                "appNotificationEnabledが正しく保存される")
        #expect(mockDefaults.bool(forKey: AppConstants.UserDefaultsKeys.isRandomTimeEnabled) == false,
                "isRandomTimeEnabledが正しく保存される")
        #expect(mockDefaults.integer(forKey: AppConstants.UserDefaultsKeys.frequencyKey) == 24,
                "selectedFrequencyが正しく保存される")
        
        if let savedBaseTime = mockDefaults.object(forKey: AppConstants.UserDefaultsKeys.baseTime) as? Date {
            #expect(abs(savedBaseTime.timeIntervalSince(testDate)) < 1.0,
                    "baseTimeが正しく保存される")
        }
        
        #expect(mockDefaults.integer(forKey: AppConstants.UserDefaultsKeys.countForReviewRequest) == 1,
                "countForReviewRequestが1回目の呼び出しでインクリメントされる")
        
        // 値を変更し、保存
        store.appNotificationEnabled = false
        store.isRandomTimeEnabled = true
        store.selectedFrequency = 48
        
        store.saveSettings()
        
        // 変更後の値を検証
        #expect(mockDefaults.bool(forKey: AppConstants.UserDefaultsKeys.appNotificationEnabled) == false,
                "変更後のappNotificationEnabledが正しく保存される")
        #expect(mockDefaults.bool(forKey: AppConstants.UserDefaultsKeys.isRandomTimeEnabled) == true,
                "変更後のisRandomTimeEnabledが正しく保存される")
        #expect(mockDefaults.integer(forKey: AppConstants.UserDefaultsKeys.frequencyKey) == 48,
                "変更後のselectedFrequencyが正しく保存される")
        
        #expect(mockDefaults.integer(forKey: AppConstants.UserDefaultsKeys.countForReviewRequest) == 2,
                "countForReviewRequestが2回目の呼び出しでインクリメントされる")
        
    }
    
    // MARK: - setNotificationList
    
    @Test func testNotificationCount() async throws {
       
        
    }
    
    @Test func testNotificationLimitMessage() async throws {
        // TODO: 最後の通知メッセージは別のメソッドを用意(20251209_2106_40)
    }
    
    @Test func testNotificationListSetFailureCount() async throws {
        // TODO: 失敗メソッドのカウントも同様に別メソッドを用意(20251209_2106_40)
    }
    
    // MARK: - removeAllNotification
    
    @Test func testNotificationsDeletedifNotificationDisabled() async throws {
        // TODO: エラーアラートの確認も含める
        // TODO: MockScheduler作成
    }
    
    
    // MARK: - getNotifiedItem
    
    @Test("通知アイテムのランダム選択テスト")
    func testGetNotifiedItem() async throws {
        
        // テスト用のリマインダーアイテムを作成
        let item1 = ReminderItem(text: "タスク1", isNotificationEnable: true, createdAt: Date())
        let item2 = ReminderItem(text: "タスク2", isNotificationEnable: true, createdAt: Date())
        let item3 = ReminderItem(text: "タスク3", isNotificationEnable: false, createdAt: Date())
        
        // 本物のNotificationStoreを使用
        let mockDefaults = MockUserDefaults()
        let store = NotificationStore(userDefaults: mockDefaults)
        
        // 有効なアイテムから選択されることを確認
        let result1 = store.getNotifiedItem(items: [item1, item2, item3])
        let enableLists = ["タスク1", "タスク2"]
        #expect(enableLists.contains(result1), "有効なアイテムから選択される")
        
        // 全て無効な場合
        let result2 = store.getNotifiedItem(items: [item3])
        #expect(result2 == "リストが空です", "全て無効な場合はデフォルトメッセージ")
        
        // 空の場合
        let result3 = store.getNotifiedItem(items: [])
        #expect(result3 == "リストが空です", "リストが空の場合はデフォルトメッセージ")
        
        // ランダム性の検証（複数回実行して異なる結果が出るか）
        var results = Set<String>()
        for _ in 0..<20 {
            let randomResult = store.getNotifiedItem(items: [item1, item2])
            results.insert(randomResult)
        }
        #expect(results.count > 1, "複数回実行で異なる結果が選択される（ランダム性）")
    }
    
    @Test("データ0件時のテスト")
    func testEmptyData() async throws {
        
        let emptyItems: [ReminderItem] = []
        
        // 本物のNotificationStoreを使用
        let mockDefaults = MockUserDefaults()
        let store = NotificationStore(userDefaults: mockDefaults)
        
        // 0件時にデフォルトメッセージが返されることを確認
        let notificationMessage = store.getNotifiedItem(items: emptyItems)
        #expect(notificationMessage == "リストが空です", "0件時にデフォルトメッセージが生成される")
        
        // 0件データでの通知作成時の処理
        let enabledItems = emptyItems.filter { $0.itemNotificationEnabled }
        let notificationTexts = enabledItems.isEmpty ? ["リストが空です"] : enabledItems.map { $0.text }
        
        #expect(enabledItems.isEmpty, "0件データでは通知有効アイテムも0件")
        #expect(notificationTexts == ["リストが空です"], "0件時は「リストが空です」が通知テキストになる")
        #expect(notificationTexts.count == 1, "デフォルトメッセージは1つ")
        
        // 複数回実行してもクラッシュしないことを確認
        for _ in 0..<10 {
            let randomMessage = store.getNotifiedItem(items: emptyItems)
            #expect(randomMessage == "リストが空です", "0件データでのランダム選択は常にデフォルトメッセージ")
        }
    }
    
    // MARK: - getFirstNotificationDate
    
    @Test func testGetFirstNotificationDate() async throws {
    }
    
    
    // MARK: - notificationTimeConverter
    
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
    
    // MARK: - その他
    
    
    @Test("TimeProvider注入テスト")
    func testTimeProviderInjection() async throws {
        let calendar = Calendar(identifier: .gregorian)
        let fixedDate = calendar.date(from: DateComponents(
            year: 2024, month: 12, day: 25,
            hour: 14, minute: 30, second: 0
        ))!
        
        let mockTime = MockTimeProvider(currentTime: fixedDate)
        let mockDefaults = MockUserDefaults()
        
        // TimeProviderを注入
        let store = NotificationStore(userDefaults: mockDefaults, timeProvider: mockTime)
        
        // baseTimeが固定時刻で初期化されることを確認
        #expect(abs(store.baseTime.timeIntervalSince(fixedDate)) < 1.0,
                "baseTimeが指定した固定時刻で初期化される")
    }
}
