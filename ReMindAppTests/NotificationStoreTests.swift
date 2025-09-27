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
}
