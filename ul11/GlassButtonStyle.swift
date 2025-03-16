import SwiftUI

struct GlassButtonStyle: ButtonStyle {
    var backgroundColor: Color = .blue
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(backgroundColor, lineWidth: 1)
            )
            .foregroundColor(backgroundColor)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}
