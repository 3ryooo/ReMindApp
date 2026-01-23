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
    
    private var testDate: Date {
        Calendar(identifier: .gregorian).date(from: DateComponents(
            year: 2024, month: 12, day: 25,
            hour: 14, minute: 30, second: 0
        ))!
    }

    
    // MARK: - requestAuthorization
    
    // TODO: 認証テストをモックで再現(20260109_2221_30)
    
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
    
    @Test("通知の作成上限数")
    func testNotificationShouldCreateAllNotifications() async throws {
        
        // TODO: createNotificationに移動
        
        let mockScheduler = MockNotificationScheduler()
        let mockDefaults = MockUserDefaults()
        
        let store = NotificationStore(scheduler: mockScheduler, userDefaults: mockDefaults)
        
        let testItems = [
            ReminderItem(text: "タスク1", isNotificationEnable: true, createdAt: Date())
        ]
        
        
        store.appNotificationEnabled = true
        store.selectedFrequency = 24
        store.setNotificationList(for: testItems)
        
        #expect(mockScheduler.addCallCount == 5, "通知の作成数がnotificationCountと同じである")
        
    }
    
    @Test("最後の通知メッセージの上限メッセージ")
    func testNotificationLimitMessage() async throws {
        
        
        // TODO: 重複コードのマージ
        
        let mockScheduler = MockNotificationScheduler()
        let mockDefaults = MockUserDefaults()
        
        let store = NotificationStore(scheduler: mockScheduler, userDefaults: mockDefaults)
        
        let testItems = [
            ReminderItem(text: "タスク1", isNotificationEnable: true, createdAt: Date())
        ]
        
        
        store.appNotificationEnabled = true
        store.selectedFrequency = 24
        store.setNotificationList(for: testItems)
        
        #expect(mockScheduler.addedRequests.last?.content.body == "\("タスク1")\n通知の上限に達しました。設定より再度「保存」をタップしてください" , "")
        
        
    }
    
    @Test("通知が失敗した場合のメッセージと件数のテスト")
    func testNotificationListSetFailureCount() async throws {
        let mockScheduler = MockNotificationScheduler()
        let mockDefaults = MockUserDefaults()
        
        let store = NotificationStore(scheduler: mockScheduler, userDefaults: mockDefaults)
        
        let testItems = [
            ReminderItem(text: "タスク1", isNotificationEnable: true, createdAt: Date())
        ]
        
        
        store.appNotificationEnabled = true
        store.selectedFrequency = 24
        store.setNotificationList(for: testItems)
        
        
        
        // ここから追記（エラーのExpect）
        
    }
    
    // MARK: - removeAllNotification
    
    @Test func testNotificationsDeletedifNotificationDisabled() async throws {
        let mockScheduler = MockNotificationScheduler()
        let mockDefaults = MockUserDefaults()
        
        let store = NotificationStore(scheduler: mockScheduler, userDefaults: mockDefaults)
        
        let testItems = [
            ReminderItem(text: "タスク1", isNotificationEnable: true, createdAt: Date()),
            ReminderItem(text: "タスク2", isNotificationEnable: true, createdAt: Date())
        ]

        store.appNotificationEnabled = false
        store.setNotificationList(for: testItems)
        
        #expect(mockScheduler.removeAllCallCount == 1, "通知無効時に削除処理が1回呼ばれる")
        #expect(mockScheduler.addCallCount == 0, "通知無効時には通知作成がスキップされる")
        #expect(store.showingNotificationErrorAlert == false, "通知無効時にはエラーアラートが表示されない")
        #expect(store.notificationErrorMessage == "", "通知無効時にはエラーメッセージが空")
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
        
        let fixedDate = testDate
        
        let mockTime = MockTimeProvider(currentTime: fixedDate)
            let mockDefaults = MockUserDefaults()
        
        let store = NotificationStore(userDefaults: mockDefaults, timeProvider: mockTime)
        let now = mockTime.now()
        
        func calculateFirstNotification(baseTime: Date, frequency: Int) throws -> Date {
            store.baseTime = baseTime
            store.selectedFrequency = frequency
            store.saveSettings()
            
            return try #require(store.getFirstNotificationDate())
        }
        
        // テストケース1: baseTimeが現在時刻の1時間前の場合
        let baseTimeInPast = try #require(Calendar.current.date(byAdding: .hour, value: -1, to: now))
        
        let actualNotificationDate1 = try calculateFirstNotification(baseTime: baseTimeInPast, frequency: 24)
        let expectedNotificationDate1 = try #require(Calendar.current.date(byAdding: .day, value: 1, to: baseTimeInPast))
        
        let timeDifference1 = Int(actualNotificationDate1.timeIntervalSince(expectedNotificationDate1))
        
        #expect(abs(timeDifference1) < 150, "翌日のbaseTimeに日付が設定される")
        #expect(actualNotificationDate1 > now, "未来に日時が設定される")
        
        // -----
        
        
        // テストケース2: baseTimeが現在時刻の1分後の場合
        let baseTimeInFuture = try #require(Calendar.current.date(byAdding: .minute, value: 1, to: now))
        
        let actualNotificationDate2 = try calculateFirstNotification(baseTime: baseTimeInFuture, frequency: 24)
        let expectedNotificationDate2 = try #require(Calendar.current.date(byAdding: .day, value: 0, to: baseTimeInFuture))
        
        let timeDifference2 = Int(actualNotificationDate2.timeIntervalSince(expectedNotificationDate2))
        
        #expect(abs(timeDifference2) < 150, "当日のbaseTimeに日付が設定される")
        #expect(actualNotificationDate2 > now, "未来に日時が設定される")
        
        
        
        // テストケース3: frequencyが1の場合
        
        let actualNotificationDate3 = try calculateFirstNotification(baseTime: baseTimeInPast, frequency: 1)
        
        // baseTimeから1時間ずつ加算してnowを超える最初の時刻
        let expectedNotificationDate3 = try #require(Calendar.current.date(byAdding: .hour, value: 1, to: now))
        
        let timeDifference3 = Int(actualNotificationDate3.timeIntervalSince(expectedNotificationDate3))
        
        #expect(abs(timeDifference3) < 150, "nowから1時間後に日付が設定される")
        #expect(actualNotificationDate3 > now, "未来に日時が設定される")
        
        // テストケース4: frequencyが6の場合
        
        let actualNotificationDate4 = try calculateFirstNotification(baseTime: baseTimeInPast, frequency: 6)
        let expectedNotificationDate4 = try #require(Calendar.current.date(byAdding: .hour, value: 6, to: baseTimeInPast))
        
        let timeDifference4 = Int(actualNotificationDate4.timeIntervalSince(expectedNotificationDate4))
        
        #expect(abs(timeDifference4) < 150, "6時間後に日時が設定される")
        #expect(actualNotificationDate4 > now, "未来に日時が設定される")
        
        // テストケース5: frequencyが12の場合
        
        let actualNotificationDate5 = try calculateFirstNotification(baseTime: baseTimeInPast, frequency: 12)
        let expectedNotificationDate5 = try #require(Calendar.current.date(byAdding: .hour, value: 12, to: baseTimeInPast))
        
        let timeDifference5 = Int(actualNotificationDate5.timeIntervalSince(expectedNotificationDate5))
        
        #expect(abs(timeDifference5) < 150, "12時間後に日時が設定される")
        #expect(actualNotificationDate5 > now, "未来に日時が設定される")
        
        // テストケース6: frequencyが48の場合
        
        let actualNotificationDate6 = try calculateFirstNotification(baseTime: baseTimeInPast, frequency: 48)
        let expectedNotificationDate6 = try #require(Calendar.current.date(byAdding: .day, value: 2, to: baseTimeInPast))
        
        let timeDifference6 = Int(actualNotificationDate6.timeIntervalSince(expectedNotificationDate6))
        
        #expect(abs(timeDifference6) < 150, "2日後に日時が設定される")
        #expect(actualNotificationDate6 > now, "未来に日時が設定される")
        
    }
    
    
    // MARK: - notificationTimeConverter
    
    @Test("複数通知の通知時間の加算テスト")
    func testNotificationTimeAddition() async throws {
        
        let basedate = testDate
        let calender  = Calendar(identifier: .gregorian)
        
        // TODO: ランダム無効を集約
        
        let mockDefaults = MockUserDefaults()
        let store = NotificationStore(userDefaults: mockDefaults)
        
        store.selectedFrequency = 24
        store.isRandomTimeEnabled = false
        
        // ID=1の場合（1日後）
        let notificationId1 = store.notificationTimeConverter(basedate, 1)
        if let date = notificationId1 {
            let components = calender.dateComponents([.day, .hour, .minute], from: date)
            #expect(components.day == 26, "日付が1日後")
            #expect(components.hour == 14, "時が変わらない")
            #expect(components.minute == 30, "分が変わらない")
        }
        
        // ID=50の場合（50日後）
        let notificationId50 = store.notificationTimeConverter(basedate, 50)
        if let date = notificationId50 {
            let components = calender.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            #expect(components.year == 2025, "日付が50日後")
            #expect(components.month == 2, "日付が50日後")
            #expect(components.day == 13, "日付が50日後")
            #expect(components.hour == 14, "時が変わらない")
            #expect(components.minute == 30, "分が変わらない")
        }
    }
    
    @Test("isDailyFrequencyの境界値テスト")
    func testDailyFrequencyBounds() async throws {
        
        let baseDate = testDate
        let calendar = Calendar(identifier: .gregorian)
        
        // NotificationStoreのインスタンス作成（モック使用）
        let mockDefaults = MockUserDefaults()
        let store = NotificationStore(userDefaults: mockDefaults)
        
        // 境界値テスト（Frequency=23 → 実行されない）
        store.selectedFrequency = 23
        store.isRandomTimeEnabled = true
        
        let exact23Date = store.notificationTimeConverter(baseDate, 1)
        if let date = exact23Date {
            let components = calendar.dateComponents([.hour, .minute], from: date)
            #expect(components.hour == 13, "23時間後は13時")
            #expect(components.minute == 30, "分は変わらない")
        }
        
        // 境界値テスト（Frequency=24 → 実行される）
        store.selectedFrequency = 24
        store.isRandomTimeEnabled = true
        
        let exact24Date = store.notificationTimeConverter(baseDate, 1)
        if let date = exact24Date {
            let baseComponents = calendar.dateComponents([.year, .month, .day], from: baseDate)
            let resultComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            
            #expect(resultComponents.year == baseComponents.year, "年は同じ")
            #expect(resultComponents.month == baseComponents.month, "月は同じ")
            #expect(resultComponents.day == (baseComponents.day! + 1), "1日後")
            #expect(resultComponents.hour != 14, "時ランダム")
            #expect(resultComponents.minute != 30, "分ランダム")
        }
        
        // 境界値テスト（Frequency=48 → 実行される）
        store.selectedFrequency = 48
        store.isRandomTimeEnabled = true
        
        let exact48Date = store.notificationTimeConverter(baseDate, 1)
        if let date = exact48Date {
            let baseComponents = calendar.dateComponents([.year, .month, .day], from: baseDate)
            let resultComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            
            #expect(resultComponents.year == baseComponents.year, "年は同じ")
            #expect(resultComponents.month == baseComponents.month, "月は同じ")
            #expect(resultComponents.day == (baseComponents.day! + 2), "2日後")
            #expect(resultComponents.hour != 14, "時ランダム")
            #expect(resultComponents.minute != 30, "分ランダム")
        }
    }
    
    // MARK: - その他
    
    
    @Test("TimeProvider注入テスト")
    func testTimeProviderInjection() async throws {
        let fixedDate = testDate
        
        let mockTime = MockTimeProvider(currentTime: fixedDate)
        let mockDefaults = MockUserDefaults()
        
        // TimeProviderを注入
        let store = NotificationStore(userDefaults: mockDefaults, timeProvider: mockTime)
        
        // baseTimeが固定時刻で初期化されることを確認
        #expect(abs(store.baseTime.timeIntervalSince(fixedDate)) < 1.0,
                "baseTimeが指定した固定時刻で初期化される")
    }
}
