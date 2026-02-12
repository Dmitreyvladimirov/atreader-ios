import Foundation

enum Endpoint {
    case loginByPassword
    case refreshToken
    case currentUser
    case userLibrary(page: Int, pageSize: Int)
    case workContent(workId: Int)
    case chapterText(workId: Int, chapterId: Int)
    case syncProgress(lastSyncTime: String?)
    case updateProgress

    var path: String {
        switch self {
        case .loginByPassword:
            return "/v1/account/login-by-password"
        case .refreshToken:
            return "/v1/account/refresh-token"
        case .currentUser:
            return "/v1/account/current-user"
        case let .userLibrary(page, pageSize):
            return "/v1/account/user-library?page=\\(page)&pageSize=\\(pageSize)"
        case let .workContent(workId):
            return "/v1/work/\\(workId)/content"
        case let .chapterText(workId, chapterId):
            return "/v1/work/\\(workId)/chapter/\\(chapterId)/text"
        case let .syncProgress(lastSyncTime):
            if let lastSyncTime, !lastSyncTime.isEmpty {
                return "/v1/account/reading-progress?lastSyncTime=\\(lastSyncTime)"
            }
            return "/v1/account/reading-progress"
        case .updateProgress:
            return "/v1/reader/update-progress"
        }
    }

    var method: String {
        switch self {
        case .loginByPassword, .refreshToken, .updateProgress:
            return "POST"
        default:
            return "GET"
        }
    }
}
