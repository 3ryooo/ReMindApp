//
//  String+Extensions.swift
//  ReMindApp
//

import Foundation

extension String {
    var isEmptyOrWhiteSpace: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
