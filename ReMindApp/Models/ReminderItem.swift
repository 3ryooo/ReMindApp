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
//    感情ログ追加予定
    
    init(id: UUID = UUID(), text: String, isNotificationEnable: Bool) {
        self.id = id
        self.text = text
        self.isNotificationEnable = isNotificationEnable
    }
}
