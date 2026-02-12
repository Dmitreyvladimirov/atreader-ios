import SwiftUI

enum ATTheme {
    static let brandBlue = Color(red: 0.29, green: 0.54, blue: 0.72)
    static let background = Color(red: 0.95, green: 0.96, blue: 0.98)
    static let cardBackground = Color.white
    static let textPrimary = Color(red: 0.20, green: 0.22, blue: 0.25)
    static let textSecondary = Color(red: 0.46, green: 0.49, blue: 0.54)
    static let successGreen = Color(red: 0.49, green: 0.76, blue: 0.34)

    static func titleFont(_ size: CGFloat = 34) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
}
