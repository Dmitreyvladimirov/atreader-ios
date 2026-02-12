import Foundation

struct APIError: Error, LocalizedError {
    let statusCode: Int
    let message: String

    var errorDescription: String? {
        "APIError(\\(statusCode)): \\(message)"
    }
}
