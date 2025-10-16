//
//  ReminderFormError.swift
//  ReMindApp
//

import Foundation

enum ReminderFormError: LocalizedError, Identifiable {
    case empty
    case overChar
    
    var id: UUID {
        UUID()
    }
    
    var errorDescription: String? {
        switch self {
        case .empty:
            return NSLocalizedString("テキストは空白にできません", comment: "")
        case .overChar:
            return NSLocalizedString("テキストは200文字までです", comment: "")
        }
    }
}
