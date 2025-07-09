//
//  ReminderFormError.swift
//  ReMindApp
//

import Foundation

enum ReminderFormError: LocalizedError, Identifiable {
    case text
    
    var id: UUID {
        UUID()
    }
    
    var errorDescription: String? {
        switch self {
        case .text:
            return NSLocalizedString("テキストは空白にできません", comment: "")
        }
    }
}
