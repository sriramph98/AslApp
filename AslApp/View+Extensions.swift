import SwiftUI

extension View {
    func checkmark(_ checked: Bool) -> some View {
        modifier(CheckmarkModifier(checked: checked))
    }
}

struct CheckmarkModifier: ViewModifier {
    let checked: Bool
    
    func body(content: Content) -> some View {
        if checked {
            content.overlay(
                Image(systemName: "checkmark")
                    .font(.system(size: 10))
                    .offset(x: -8)
            )
        } else {
            content
        }
    }
} 