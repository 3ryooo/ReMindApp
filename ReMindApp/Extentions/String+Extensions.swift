//
//  String+Extensions.swift
//  ReMindApp
//

import Foundation

extension String {
    
    // TODO: text用の必要なバリデーションを確認
    
    var isEmptyOrWhiteSpace: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var isOver200Characters: Bool {
        count > 200
    }
}
