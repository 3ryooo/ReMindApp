//
//  String+Extensions.swift
//  ReMindApp
//

import Foundation

extension String {
    
    var isEmptyOrWhiteSpace: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var isOver200Characters: Bool {
        count > 200
    }
}
