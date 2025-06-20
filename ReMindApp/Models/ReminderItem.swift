//
//  ReminderItem.swift
//  ReMindApp
//

import Foundation
import SwiftData

@Model
class ReminderItem: Identifiable {
    var id: UUID
    var text: String
    var isNotificationEnable: Bool
    var createdAt: Date
    
//    感情ログ追加予定
    
    init(id: UUID = UUID(), text: String, isNotificationEnable: Bool, createdAt: Date) {
        self.id = id
        self.text = text
        self.isNotificationEnable = isNotificationEnable
        self.createdAt = createdAt
    }
}
