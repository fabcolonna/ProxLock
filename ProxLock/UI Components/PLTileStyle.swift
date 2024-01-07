import SwiftUI

struct PLTileStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 13)
            .shadow(color: Color.green.opacity(0.2), radius: 20, x: 0, y: 0)

    }
}

extension View {
    func applyPLTileStyle() -> some View {
        self.modifier(PLTileStyle())
    }
}
