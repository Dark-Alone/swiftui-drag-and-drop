
import SwiftUI

@available(iOS 14, *)
public struct DragButton: View {
    public init() { }
    
    public var body: some View {
        ScrollViewGestureButton(
            dragStartAction: { value in
                print("drag start action")
            }, dragAction: { value in
                print("drag action \(value)")
            }, dragEndAction: { value in
                print("drag end action \(value)")
            }) { isPressed in
                Text(isPressed ? "THIS BUTTON PRESSED" : "PRESS ME TO SEE SOMETHING")
            }
    }
}

