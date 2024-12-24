import SwiftUI

enum AppTheme {
    static let primaryColor = Color("PrimaryColor")
    static let secondaryColor = Color("SecondaryColor")
    static let backgroundColor = Color(.systemGroupedBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    
    static let cornerRadius: CGFloat = 12
    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 8
    
    struct CardStyle: ViewModifier {
        @Environment(\.colorScheme) var colorScheme
        
        func body(content: Content) -> some View {
            content
                .padding(AppTheme.padding)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.cornerRadius)
                .shadow(
                    color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.1),
                    radius: colorScheme == .dark ? 3 : 5,
                    x: 0,
                    y: colorScheme == .dark ? 2 : 2
                )
        }
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(AppTheme.CardStyle())
    }
} 