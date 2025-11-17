//
//  TimeProvider.swift
//  ReMindApp
//

import Foundation

protocol TimeProvider {
    func now() -> Date
}

struct DefaultTimeProvider: TimeProvider {
    func now() -> Date {
        Date()
    }
}

