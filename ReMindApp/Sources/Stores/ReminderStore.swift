//
//  RemindStore.swift
//  ReMindApp
//

import Foundation
import Observation
import SwiftData



@Observable
class ReminderStore {
    
    // MARK: - プロパティ
    var sortOption: SortOption = .timestamp
    var showingAddReminderSheet = false
    var showingAddSettingSheet = false
    
    // MARK: - ソートメソッド
    func getSortedItems (_ items: [ReminderItem]) -> [ReminderItem] {
        var filtered = items
        
        switch sortOption {
        case .name:
            filtered.sort {$0.text < $1.text}
        case .timestamp:
            filtered.sort {$0.createdAt > $1.createdAt}
        }
        return filtered
    }
    
    // MARK: - データ管理
    func deleteItems(at offsets: IndexSet, from items: [ReminderItem], context: ModelContext) {
        for index in offsets {
            context.delete(items[index])
        }
    }
    
    // MARK: - サンプルデータ
    func addSampleReminder(context: ModelContext) {
        
        do {
            try context.delete(model: ReminderItem.self)
            print("モデル削除成功")
        } catch {
            print("モデル削除失敗")
        }
        
        let sampleData: [(String, Bool, Date)] = [
            ("未来を予測する最善の方法は、それを発明することだ。", false, Date(timeIntervalSinceNow: -432000)),
            ("千里の道も一歩から。", true, Date(timeIntervalSinceNow: 129600)),
            ("成功とは、情熱を失わずに失敗を重ねることである。", true, Date(timeIntervalSinceNow: -587321)),
            ("人生は自転車のようなものだ。倒れないようにするには走り続けなければならない。", false, Date(timeIntervalSinceNow: 345600)),
            ("困難の中に機会がある。", true, Date(timeIntervalSinceNow: 86400)),
            ("夢見ることができれば、それは実現できる。", false, Date(timeIntervalSinceNow: -259200)),
            ("唯一の真の知恵は、自分が何も知らないということを知ることにある。", true, Date(timeIntervalSinceNow: 518400)),
            ("行動はすべての成功の基本的な鍵である。", false, Date(timeIntervalSinceNow: -172800)),
            ("学び続ける限り、人は老いない。", true, Date(timeIntervalSinceNow: -302400)),
            ("幸福は目的地ではない。旅の仕方だ。", true, Date(timeIntervalSinceNow: 216000))
        ]
        
        for (text, isEnabled, date) in sampleData {
            let item = ReminderItem(
                text: text,
                isNotificationEnable: isEnabled,
                createdAt: date
            )
            context.insert(item)
        }
        
    }
    
}
