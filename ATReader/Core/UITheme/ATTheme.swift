import SwiftUI

enum ATTheme {
    static let brandBlue = Color(red: 0.29, green: 0.54, blue: 0.72)
    static let background = Color(uiColor: .systemGroupedBackground)
    static let cardBackground = Color(uiColor: .systemBackground)
    static let textPrimary = Color(uiColor: .label)
    static let textSecondary = Color(uiColor: .secondaryLabel)
    static let successGreen = Color(red: 0.49, green: 0.76, blue: 0.34)

    static func titleFont(_ size: CGFloat = 34) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
}
