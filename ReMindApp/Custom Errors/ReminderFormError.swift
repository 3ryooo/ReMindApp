//
//  ReminderFormError.swift
//  ReMindApp
//

import Foundation

// 現在未使用（複数のバリデーション発生時使用予定）
enum ReminderFormError: LocalizedError, Identifiable {
    case text
    
    var id: UUID {
        UUID()
    }
    
    // TODO: バリデーション設定（文字数？）
    var errorDescription: String? {
        switch self {
        case .text:
            return NSLocalizedString("テキストは空白にできません", comment: "")
        }
    }
}
