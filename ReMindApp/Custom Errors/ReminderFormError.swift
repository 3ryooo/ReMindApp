//
//  ReminderFormError.swift
//  ReMindApp
//

import Foundation

// 現在未使用（複数のバリデーション発生時使用予定）
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
