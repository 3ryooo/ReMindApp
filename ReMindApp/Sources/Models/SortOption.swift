//
//  SortOption.swift
//  ReMindApp
//

import Foundation

enum SortOption: CaseIterable {
    case name
    case timestamp
    
    var displayTitle: String {
        switch self {
        case .name:
            return "名前順"
        case .timestamp:
            return "新しい順"
        }
    }
} 