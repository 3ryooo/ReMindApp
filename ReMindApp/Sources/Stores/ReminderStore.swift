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
            ("未来を予測する最善の方法は、それを発明することだ。", true, Date(timeIntervalSinceNow: -259200)),
            ("話すのは簡単だ。コードを見せてくれ。", true, Date(timeIntervalSinceNow: -86400)),
            ("完璧を目指すよりまず終わらせよ。", true, Date(timeIntervalSinceNow: -604800)),
            ("成功とは、情熱を失わずに失敗を重ねることである。", true, Date(timeIntervalSinceNow: -345600)),
            ("人生は自転車のようなものだ。倒れないようにするには走り続けなければならない。", true, Date(timeIntervalSinceNow: 172800)),
            ("休息は怠惰ではない。", true, Date(timeIntervalSinceNow: 432000)),
            ("明日死ぬかのように生き、永遠に生きるかのように学べ。", true, Date(timeIntervalSinceNow: 0)),
            ("千里の道も一歩から。", false, Date(timeIntervalSinceNow: -864000)),
            ("困難の中に機会がある。", true, Date(timeIntervalSinceNow: -2592000)),
            ("我々は繰り返し行うことの集大成である。したがって卓越性は行為ではなく習慣である。", true, Date(timeIntervalSinceNow: 518400)),
            ("行動はすべての成功の基本的な鍵である。", true, Date(timeIntervalSinceNow: -172800)),
            ("夢見ることができれば、それは実現できる。", true, Date(timeIntervalSinceNow: -129600)),
            ("学び続ける限り、人は老いない。", true, Date(timeIntervalSinceNow: -302400)),
            ("幸福は目的地ではない。旅の仕方だ。", true, Date(timeIntervalSinceNow: 216000)),
            ("最大の栄光は一度も失敗しないことではなく、倒れるたびに立ち上がることにある。", true, Date(timeIntervalSinceNow: -691200)),
            ("変化こそ唯一の永遠である。", true, Date(timeIntervalSinceNow: 86400)),
            ("やるかやらないかだ。試しなどない。", true, Date(timeIntervalSinceNow: -432000)),
            ("知識に投資することが、常に最高の利益を生む。", true, Date(timeIntervalSinceNow: 259200)),
            ("始めることがすべての半分だ。", true, Date(timeIntervalSinceNow: -777600)),
            ("時間は最も希少な資源である。", true, Date(timeIntervalSinceNow: 604800)),
            ("できると思えばできる。できないと思えばできない。", true, Date(timeIntervalSinceNow: -950400)),
            ("努力は必ず報われるとは限らない。しかし成功した者は皆努力している。", true, Date(timeIntervalSinceNow: -518400)),
            ("今日という日は、残りの人生の最初の日である。", true, Date(timeIntervalSinceNow: 129600)),
            ("チャンスは準備された心に降り立つ。", true, Date(timeIntervalSinceNow: -1209600)),
            ("自分にできることを、できる場所で、できるときに行え。", true, Date(timeIntervalSinceNow: 345600)),
            ("恐れは無知から生まれる。", false, Date(timeIntervalSinceNow: -864000)),
            ("継続は力なり。", true, Date(timeIntervalSinceNow: -1728000)),
            ("挑戦なくして成長なし。", true, Date(timeIntervalSinceNow: 777600)),
            ("小さな進歩でも前進は前進だ。", true, Date(timeIntervalSinceNow: -259200)),
            ("成功は準備と機会が出会ったときに生まれる。", true, Date(timeIntervalSinceNow: 432000)),
            ("行動しなければ、何も変わらない。", true, Date(timeIntervalSinceNow: -648000)),
            ("忍耐は苦いが、その実は甘い。", true, Date(timeIntervalSinceNow: 259200)),
            ("自分を信じることが第一歩である。", true, Date(timeIntervalSinceNow: -432000)),
            ("限界は思い込みに過ぎない。", true, Date(timeIntervalSinceNow: 864000)),
            ("成功への道は常に工事中である。", true, Date(timeIntervalSinceNow: -1036800)),
            ("習慣が人格を作る。", true, Date(timeIntervalSinceNow: 172800)),
            ("努力は才能を上回る。", true, Date(timeIntervalSinceNow: -345600)),
            ("思考を変えれば、人生が変わる。", true, Date(timeIntervalSinceNow: 691200)),
            ("焦らず、しかし休まず。", true, Date(timeIntervalSinceNow: -518400)),
            ("未来は今日何をするかで決まる。", true, Date(timeIntervalSinceNow: 432000)),
            ("成功は最終ではなく、失敗は致命的ではない。重要なのは続ける勇気だ。", true, Date(timeIntervalSinceNow: -259200)),
            ("最も暗い夜でも、朝は訪れる。", true, Date(timeIntervalSinceNow: 86400)),
            ("行き詰まったときこそ、新しい道が開ける。", true, Date(timeIntervalSinceNow: -604800)),
            ("一歩ずつでも前に進め。", true, Date(timeIntervalSinceNow: 518400)),
            ("挑戦する者だけが成功を手にする。", true, Date(timeIntervalSinceNow: -777600)),
            ("昨日より今日、今日より明日。", true, Date(timeIntervalSinceNow: 259200)),
            ("可能性は挑戦する者にのみ見える。", true, Date(timeIntervalSinceNow: -345600)),
            ("考えるだけではなく、行動せよ。", true, Date(timeIntervalSinceNow: 172800)),
            ("始めなければ、始まらない。", true, Date(timeIntervalSinceNow: -432000)),
            ("夢は逃げない。逃げるのはいつも自分だ。", true, Date(timeIntervalSinceNow: 604800))
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
