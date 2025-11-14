//
//  UserDefaultsProtocol.swift
//  ReMindApp
//

import Foundation

protocol UserDefaultsProtocol {
    func bool(forKey key: String) -> Bool
    func integer(forKey key: String) -> Int
    func object(forKey key: String) -> Any?
    func set(_ value: Bool, forKey key: String)
    func set(_ value: Int, forKey key: String)
    func set(_ value: Any?, forKey key: String)
}

extension UserDefaults: UserDefaultsProtocol {}

