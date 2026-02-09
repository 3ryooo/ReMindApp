//
//  ReminderItem.swift
//  ReMindApp
//

import Foundation
import SwiftData

@Model
final class ReminderItem: Identifiable {
    
    // TODO: CloudKitのDeploy(20260209_1953_16)
    
    var id: UUID = UUID()
    var text: String = ""
    var itemNotificationEnabled: Bool = false
    var createdAt: Date = Date()
    
    
    @Transient
    var errorMessages: [ReminderFormError] = []
    
    
    init(text: String, isNotificationEnable: Bool, createdAt: Date) {
        self.text = text
        self.itemNotificationEnabled = isNotificationEnable
        self.createdAt = createdAt
    }
    
    
    func validate() -> Bool {
        
        errorMessages.removeAll()
        
        if text.isEmptyOrWhiteSpace {
            errorMessages.append(.empty)
        }
        
        if text.isOver200Characters {
            errorMessages.append(.overChar)
        }
        
        return errorMessages.isEmpty
    }
    
    
}
