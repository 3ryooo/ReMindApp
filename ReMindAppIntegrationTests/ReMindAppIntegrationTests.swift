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
    
    // TODO: 詳細の統合テストを作成（VSCODEのメモから引用）

}
