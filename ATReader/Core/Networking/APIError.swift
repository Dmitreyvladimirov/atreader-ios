import Foundation

struct APIError: Error, LocalizedError {
    let statusCode: Int
    let message: String

    var errorDescription: String? {
        userFacingMessage
    }

    var userFacingMessage: String {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = trimmed.lowercased()

        if lower.contains("<!doctype html") || lower.contains("<html") {
            return String(localized: "error.server_unexpected_html") + " (\(statusCode))"
        }

        let normalized = trimmed.replacingOccurrences(of: "\n", with: " ")
        if normalized.count > 240 {
            return "APIError(\(statusCode)): " + String(normalized.prefix(240)) + "..."
        }
        return "APIError(\(statusCode)): \(normalized)"
    }
}
