
import SwiftUI

@available(iOS 14, *)
struct DragableButtonActions {
    var pressAction: ScrollViewGestureButton.Action?
    var releaseInsideAction: ScrollViewGestureButton.Action?
}

@available(iOS 14, *)
struct DragableButton: ViewModifier, DragableModifier {
    @State private var dragOffset = CGSize.zero
    @State private var dragState = DragState.none
    let dragableObject: Dragable?
    
    var onDragObject: ((Dragable, CGPoint) -> DragState)? = nil
    var onDragged: ((CGPoint) -> DragState)? = nil
    var onDropObject: ((Dragable, CGPoint) -> Bool)? = nil
    var onDropped: ((CGPoint) -> Bool)? = nil
    
    var buttonActions: DragableButtonActions?
    
    init(onDragged: @escaping ((CGPoint) -> DragState), onDropped: @escaping ((CGPoint) -> Bool), buttonActions: DragableButtonActions? = nil) {
        self.dragableObject = nil
        self.onDragged = onDragged
        self.onDropped = onDropped
        self.buttonActions = buttonActions
    }
    
    init(object: Dragable, onDragged: @escaping ((CGPoint) -> DragState), onDropObject: @escaping ((Dragable, CGPoint) -> Bool), buttonActions: DragableButtonActions? = nil) {
        self.dragableObject = object
        self.onDragged = onDragged
        self.onDropObject = onDropObject
        self.buttonActions = buttonActions
    }
    
    init(object: Dragable, onDragObject: @escaping ((Dragable, CGPoint) -> DragState), onDropped: @escaping ((CGPoint) -> Bool), buttonActions: DragableButtonActions? = nil) {
        self.dragableObject = object
        self.onDragObject = onDragObject
        self.onDropped = onDropped
        self.buttonActions = buttonActions
    }
    
    init(object: Dragable, onDragObject: @escaping ((Dragable, CGPoint) -> DragState), onDropObject: @escaping ((Dragable, CGPoint) -> Bool), buttonActions: DragableButtonActions? = nil) {
        self.dragableObject = object
        self.onDragObject = onDragObject
        self.onDropObject = onDropObject
        self.buttonActions = buttonActions
    }
    
    public typealias Action = ScrollViewGestureButton<Content>.Action
    public typealias DragAction = ScrollViewGestureButton<Content>.DragAction
    public typealias LabelBuilder = ScrollViewGestureButton<Content>.LabelBuilder
    
    
    public func body(content: Content) -> some View {
        ScrollViewGestureButton(
            pressAction: buttonActions?.pressAction,
            releaseInsideAction: buttonActions?.releaseInsideAction,
            dragStartAction: { gesture in
                
            },
            dragAction: { gesture in
                print("drag action")
                self.dragOffset = CGSize(
                    width: gesture.translation.width,
                    height: gesture.translation.height)
                withAnimation(.linear(duration: DrawingConstants.dragStateOnChangedTransitionDuration)) {
                    self.dragState = self.onDragged != nil ? self.onDragged!(gesture.location) : self.onDragObject!(dragableObject!, gesture.location)
                }
            },
            dragEndAction: { gesture in
                print("drag end action")
                let successfulDrop = self.onDropped != nil ? self.onDropped!(gesture.location) : self.onDropObject!(dragableObject!, gesture.location)
                withAnimation(.linear(duration: DrawingConstants.dragStateOnEndedTransitionDuration)) {
                    self.dragState = .none
                }
                withAnimation(successfulDrop ? .none : .linear) {
                    self.dragOffset = .zero
                }
            },
            endAction: {
                
            }) { _ in
                content
            }
            .offset(x: dragOffset.width, y: dragOffset.height)
    }
}

@available(iOS 14, *)
extension DragableButton {
    init() {
        print("init Button")
        self.dragableObject = nil
        self.onDragged = defaultOnDragged
        self.onDropped = defaultOnDropped
        self.buttonActions = DragableButtonActions(pressAction: {
            print("press action")
        }, releaseInsideAction: {
            print("release inside action")
        })
    }
    
    private func defaultOnDragged(_: CGPoint) -> DragState { .unknown }
    private func defaultOnDropped(_: CGPoint) -> Bool { false }
}

@available(iOS 14, *)
extension View {
    public func dragableButton() -> some View {
        modifier(DragableButton())
    }
}
