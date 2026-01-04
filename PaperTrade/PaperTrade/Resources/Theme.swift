import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let primary = Color("Primary")           // Coral #FF6B6B
    let secondary = Color("Secondary")       // Teal #4ECDC4
    let accent = Color("Accent")             // Sunny Yellow #FFE66D
    let gains = Color("Gains")               // Fresh Green #34D399
    let losses = Color("Losses")             // Soft Red #F87171
    let background = Color("Background")     // White #FFFFFF
    let cardBackground = Color("CardBackground") // Light Gray #F8FAFC
    let textPrimary = Color("TextPrimary")   // Dark Gray #1E293B
    let textSecondary = Color("TextSecondary") // Medium Gray #64748B
}

// Fallback colors when asset catalog isn't available
extension Color {
    static let primaryCoral = Color(hex: "FF6B6B")
    static let secondaryTeal = Color(hex: "4ECDC4")
    static let accentYellow = Color(hex: "FFE66D")
    static let gainsGreen = Color(hex: "34D399")
    static let lossesRed = Color(hex: "F87171")
    static let backgroundWhite = Color(hex: "FFFFFF")
    static let cardGray = Color(hex: "F8FAFC")
    static let textDark = Color(hex: "1E293B")
    static let textMedium = Color(hex: "64748B")
}

// Hex color initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
