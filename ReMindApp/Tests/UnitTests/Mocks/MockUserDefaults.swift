//
//  MockUserDefaults.swift
//  ReMindAppTests
//

import Foundation

/// テスト用のUserDefaultsモック
class MockUserDefaults: UserDefaultsProtocol {
    private var storage: [String: Any] = [:]
    
    func bool(forKey key: String) -> Bool {
        storage[key] as? Bool ?? false
    }
    
    func integer(forKey key: String) -> Int {
        storage[key] as? Int ?? 0
    }
    
    func object(forKey key: String) -> Any? {
        storage[key]
    }
    
    func set(_ value: Bool, forKey key: String) {
        storage[key] = value
    }
    
    func set(_ value: Int, forKey key: String) {
        storage[key] = value
    }
    
    func set(_ value: Any?, forKey key: String) {
        storage[key] = value
    }
}

