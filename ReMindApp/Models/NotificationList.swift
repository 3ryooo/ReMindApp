//
//  NotificationList.swift
//  ReMindApp
//

import Foundation
import SwiftData

@Model
final class NotificationList {
    var id: String = ""
    var content: String = ""
    var notificationDate: Date = Date()
    
    init(id: String, content: String, notificationDate: Date) {
        self.id = id
        self.content = content
        self.notificationDate = notificationDate
    }
}
