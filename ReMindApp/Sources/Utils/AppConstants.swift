import Foundation

struct AppConstants {
    // TODO: （待ち）本番用の値に変更
    static let notificationCount = 5

    struct UserDefaultsKeys {
        static let appNotificationEnabled = "appNotificationEnabled"
        static let isRandomTimeEnabled = "isRandomTimeEnabled"
        static let frequencyKey = "frequencyKey"
        static let baseTime = "baseTime"
        static let countForReviewRequest = "countForReviewRequest"
    }
}
