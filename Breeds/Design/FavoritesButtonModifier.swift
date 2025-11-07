import SwiftUI

struct FavoritesButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding()
            .frame(minWidth: .favoritesButtonMinWidth)
            .background(
                RoundedRectangle(cornerRadius: .favoritesButtonCornerRadius)
                    .fill(.gray)
                    .shadow()
            )
            .padding(.vertical, .favoritesButtonVerticalPadding)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
    }
}

private extension CGFloat{
    static let favoritesButtonMinWidth: Self = 220
    static let favoritesButtonVerticalPadding: Self = 12
    static let favoritesButtonCornerRadius: Self = 12
}


extension View {
    func favoritesButtonStyle() -> some View {
        self.modifier(FavoritesButtonModifier())
    }
}

