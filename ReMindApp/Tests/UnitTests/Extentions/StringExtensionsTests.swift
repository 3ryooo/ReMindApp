//
//  StringExtensionsTests.swift
//  ReMindApp
//

import Testing
import Foundation
@testable import ReMindApp

struct StringExtensionsTests {
    @Test("空文字・空白文字のテスト")
    func testStringIsEmptyOrWhiteSpace() async throws {
        
        let emptyString = ""
        #expect(emptyString.isEmptyOrWhiteSpace == true, "空文字→true")
        
        let whitespaceString = "   "
        #expect(whitespaceString.isEmptyOrWhiteSpace == true, "空白→true")
        
        let validString = "テスト"
        #expect(validString.isEmptyOrWhiteSpace == false, "文字列→false")
        
        let stringWithSpaces = "  テスト  "
        #expect(stringWithSpaces.isEmptyOrWhiteSpace == false, "文字列+空白→false")
    }
}
