import SwiftUI

struct ShadowModifier: ViewModifier{
    func body(content: Content) -> some View {
        content.shadow(color: Color(.systemGray3), radius: 4, x: 0, y: 2)
    }
}

extension View {
    func shadow() -> some View {
        self.modifier(ShadowModifier())
    }
}
