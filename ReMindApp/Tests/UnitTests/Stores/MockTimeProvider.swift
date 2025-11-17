//
//  MockTimeProvider.swift
//  ReMindAppTests
//

import Foundation

class MockTimeProvider: TimeProvider {
    private var currentTime: Date
    
    init(currentTime: Date = Date()) {
        self.currentTime = currentTime
    }
    
    func now() -> Date {
        currentTime
    }
    
    /// テスト用の時刻を設定
    func setTime(_ date: Date) {
        currentTime = date
    }
}

