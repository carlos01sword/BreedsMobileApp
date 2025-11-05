import SwiftUI

struct CardImageStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: ConstantsUI.imageCardFrameSize, height: ConstantsUI.imageCardFrameSize)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: ConstantsUI.largeCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ConstantsUI.largeCornerRadius, style: .continuous)
                    .stroke(Color.gray.opacity(ConstantsUI.shimmerBaseOpacity))
            )
            .shadow()
            .padding(.top)
    }
}

extension View {
    func cardImageStyle() -> some View {
        self.modifier(CardImageStyle())
    }
}
