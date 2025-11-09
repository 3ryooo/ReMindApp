//
//  DateConverterTests.swift
//  ReMindAppTests
//

import Testing
import Foundation
@testable import ReMindApp

struct DateConverterTests {

    @Test("日本時間フォーマットの確認")
    func testDateConverterJapanTime() async throws {
        
        let dateConverter = DateConverter()
        
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.year = 2024
        components.month = 12
        components.day = 25
        components.hour = 15
        components.minute = 30
        components.second = 45
        components.timeZone = TimeZone(identifier: "UTC")
        
        guard let testDate = calendar.date(from: components) else {
            Issue.record("テスト用の日付を作成できませんでした")
            return
        }
        
        let result = dateConverter.japanTime(testDate)
        
        let expectedFormat = "2024/12/26 00:30:45"
        
        #expect(result == expectedFormat,
                "日時が一致しません 正しい値: \(expectedFormat), 実際の値: \(result)")
    }

}
