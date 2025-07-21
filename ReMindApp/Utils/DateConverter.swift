//
//  DateConverter.swift
//  ReMindApp
//

import Foundation

class DateConverter {
    func japanTime(_ dateTime: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        return formatter.string(from: dateTime)
    }
}
