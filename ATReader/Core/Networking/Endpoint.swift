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
        case .userLibrary:
            return "/v1/account/user-library"
        case let .workContent(workId):
            return "/v1/work/\(workId)/content"
        case let .chapterText(workId, chapterId):
            return "/v1/work/\(workId)/chapter/\(chapterId)/text"
        case .syncProgress:
            return "/v1/account/reading-progress"
        case .updateProgress:
            return "/v1/reader/update-progress"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case let .userLibrary(page, pageSize):
            return [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "pageSize", value: String(pageSize))
            ]
        case let .syncProgress(lastSyncTime):
            guard let lastSyncTime, !lastSyncTime.isEmpty else { return nil }
            return [URLQueryItem(name: "lastSyncTime", value: lastSyncTime)]
        default:
            return nil
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
