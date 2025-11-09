//
//  ReMindAppIntegrationTests.swift
//  ReMindAppIntegrationTests
//

import Testing
import Foundation
import SwiftData
import UserNotifications
@testable import ReMindApp

struct ReMindAppIntegrationTests {
    
    @Test("リマインダー保存の基本テスト")
    @MainActor
    func testReminderSaving() async throws {
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ReminderItem.self, configurations: config)
        let context = container.mainContext
        
        let reminder = ReminderItem(text: "テスト用リマインダー", isNotificationEnable: true, createdAt: Date())
        context.insert(reminder)
        try context.save()
        
        let savedItems = try context.fetch(FetchDescriptor<ReminderItem>())
        #expect(savedItems.count == 1, "1つのリマインダーが保存される")
        #expect(savedItems.first?.text == "テスト用リマインダー", "正しいテキストが保存される")
        
    }
    
    @Test("リマインダー作成から通知設定までの完全なフロー")
    @MainActor
    func testCompleteReminderToNotificationFlow() async throws {
        
        // SwiftDataのメモリ内データベースを作成（テスト用）
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ReminderItem.self, configurations: config)
        let context = container.mainContext
        let notificationStore = NotificationStore()
        
        print("リマインダーアイテムを作成")
        
        // 新しいリマインダーを作成（実際のアプリでユーザーが入力する内容）
        let testReminderText = "テスト"
        let testReminder = ReminderItem(
            text: testReminderText,
            isNotificationEnable: true,
            createdAt: Date()
        )
        
        context.insert(testReminder)
        try context.save()
        
        // 保存されたかを確認
        let savedItems = try context.fetch(FetchDescriptor<ReminderItem>())
        #expect(savedItems.count == 1, "リマインダーが1つ保存される")
        #expect(savedItems.first?.text == testReminderText, "保存されたテキストが正しい")
        #expect(savedItems.first?.isNotificationEnable == true, "通知が有効になっている")
        
        print("通知設定")
        
        notificationStore.isNotificationEnabled = true
        notificationStore.selectedFrequency = 24
        notificationStore.isRandomTimeEnabled = false
        notificationStore.baseTime = Date()
        
        print("通知リスト作成")
        
        // 実際のアプリで「保存」ボタンを押したときの処理をシミュレート
        notificationStore.setNotificationList(for: savedItems)
        

        let pendingNotifications = await UNUserNotificationCenter.current().pendingNotificationRequests()
        
        #expect(pendingNotifications.count > 0, "通知リストが作成される")
        #expect(pendingNotifications.count <= 5, "通知数が上限以下である")  // アプリの制限
        
        if let firstNotification = pendingNotifications.first {
            let content = firstNotification.content.body
            #expect(content.contains(testReminderText), "通知内容がリマインダーテキストを含む")
            
            if let trigger = firstNotification.trigger as? UNCalendarNotificationTrigger,
               let nextTriggerDate = trigger.nextTriggerDate() {
                #expect(nextTriggerDate > Date(), "通知日時が未来の時刻")
                print("内容: \(content)")
                print("予定時刻: \(nextTriggerDate)")
            }
        }
        
        
        print("データ整合性確認")
        
        // リマインダーと通知の関連性をチェック
        let enabledReminders = savedItems.filter { $0.isNotificationEnable }
        #expect(enabledReminders.count > 0, "通知有効なリマインダーが存在")

        let notificationContents = pendingNotifications.map { $0.content.body }
        let enabledTexts = enabledReminders.map { $0.text }
        
        for content in notificationContents {
            if content != "リストが空です" {
                let containsValidText = enabledTexts.contains { content.contains($0) }
                #expect(containsValidText, "通知内容が有効なリマインダーから作成されている")
            }
        }
        
        print("設定変更時の動作を確認")
        
        // 非同期処理の完了を待つ
        try await Task.sleep(for: .milliseconds(300))
        
        notificationStore.isNotificationEnabled = false
        
        // 削除前の通知数を確認
        let beforeDeleteNotifications = await UNUserNotificationCenter.current().pendingNotificationRequests()
        print("通知数（削除前）: \(beforeDeleteNotifications.count)")
        
        // 実際のアプリでの動作をシミュレート（SettingsScreenの処理と同じ）
        if notificationStore.isNotificationEnabled {
            notificationStore.setNotificationList(for: savedItems)
        } else {
            notificationStore.removeAllNotification()
            print("removeAllNotification完了")
        }
        
        // 非同期処理の完了を待つ
        try await Task.sleep(for: .milliseconds(100))
        
        let remainingNotifications = await UNUserNotificationCenter.current().pendingNotificationRequests()
        print("削除後の通知数（削除後）: \(remainingNotifications.count)")
        
        #expect(remainingNotifications.count == 0, "通知無効時に全ての通知が削除される")
        
        
        // 最終チェック：リマインダーはまだ存在する
        let finalReminders = try context.fetch(FetchDescriptor<ReminderItem>())
        
        #expect(finalReminders.count == 1, "リマインダーは残っている")
        
    }
    
    @Test("空文字列と特殊文字の処理テスト")
    func testSpecialCharacterHandling() async throws {
        
        let problematicStrings = [
            "", // 空文字
            "   ", // 空白
            "🎉🎊✨",
            "ああああああああああああああああああああああああああああああああああああああああああああ", // 長い日本語
            "Line1\nLine2\nLine3", // 改行文字
            "\"Quote\" 'Single' `Backtick`", // 引用符
            "<script>alert('test')</script>", // HTMLタグ
            "Test with    multiple   spaces", // 複数スペース
        ]
        
        for testString in problematicStrings {
            // 空文字・空白のみの場合のバリデーション
            let isEmpty = testString.isEmptyOrWhiteSpace
            if testString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                #expect(isEmpty == true, "空文字・空白のみは正しく検出される: '\(testString)'")
            } else {
                #expect(isEmpty == false, "有効な文字列は正しく検出される: '\(testString)'")
                
                let item = ReminderItem(text: testString, isNotificationEnable: true, createdAt: Date())
                #expect(item.text == testString, "特殊文字を含む文字列が正しく保存される")
                
                // 通知メッセージとして使用可能か
                let notificationBody = item.text
                #expect(!notificationBody.isEmpty, "通知メッセージとして空でない文字列が生成される")
            }
        }
    }

}
