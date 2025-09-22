//
//  ReminderItem.swift
//  ReMindApp
//

import Foundation
import SwiftData

@Model
final class ReminderItem: Identifiable {
    var id: UUID = UUID()
    var text: String = ""
    var isNotificationEnable: Bool = false
    var createdAt: Date = Date()
    
    //    @Transient
    //    var errorMessages: [ReminderFormError] = []
    
    //    TODO: （保留）感情ログ追加予定
    
    init(text: String, isNotificationEnable: Bool, createdAt: Date) {
        self.text = text
        self.isNotificationEnable = isNotificationEnable
        self.createdAt = createdAt
    }
    
    // 現在未使用（複数のバリデーション発生時使用予定）
//    func validate() -> Bool {
//        
//        errorMessages.removeAll()
//        
//        if text.isEmptyOrWhiteSpace {
//            errorMessages.append(.text)
//        }
//        
//        return errorMessages.isEmpty
//    }
    
    
}
