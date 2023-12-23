
import SwiftUI

@available(iOS 14, *)
public struct DragableButtonActions {
    var pressAction: ScrollViewGestureButton.Action?
    var releaseInsideAction: ScrollViewGestureButton.Action?
    
    public init(pressAction: ScrollViewGestureButton.Action? = nil, releaseInsideAction: ScrollViewGestureButton.Action? = nil) {
        self.pressAction = pressAction
        self.releaseInsideAction = releaseInsideAction
    }
}

@available(iOS 14, *)
public struct DragableButton<Label: View>: View, DragableModifier {
    @State private var dragOffset = CGSize.zero
    @State private var dragState = DragState.none
    let dragableObject: Dragable?
    
    var onDragObject: ((Dragable, CGPoint) -> DragState)? = nil
    var onDragged: ((CGPoint) -> DragState)? = nil
    var onDropObject: ((Dragable, CGPoint) -> Bool)? = nil
    var onDropped: ((CGPoint) -> Bool)? = nil
    
    var buttonActions: DragableButtonActions?
    
    var label: LabelBuilder
    
    public init(onDragged: @escaping ((CGPoint) -> DragState), onDropped: @escaping ((CGPoint) -> Bool), buttonActions: DragableButtonActions? = nil, label: @escaping LabelBuilder) {
        self.dragableObject = nil
        self.onDragged = onDragged
        self.onDropped = onDropped
        self.buttonActions = buttonActions
        self.label = label
    }
    
    public init(object: Dragable, onDragged: @escaping ((CGPoint) -> DragState), onDropObject: @escaping ((Dragable, CGPoint) -> Bool), buttonActions: DragableButtonActions? = nil, label: @escaping LabelBuilder) {
        self.dragableObject = object
        self.onDragged = onDragged
        self.onDropObject = onDropObject
        self.buttonActions = buttonActions
        self.label = label
    }
    
    public init(object: Dragable, onDragObject: @escaping ((Dragable, CGPoint) -> DragState), onDropped: @escaping ((CGPoint) -> Bool), buttonActions: DragableButtonActions? = nil, label: @escaping LabelBuilder) {
        self.dragableObject = object
        self.onDragObject = onDragObject
        self.onDropped = onDropped
        self.buttonActions = buttonActions
        self.label = label
    }
    
    public init(object: Dragable, onDragObject: @escaping ((Dragable, CGPoint) -> DragState), onDropObject: @escaping ((Dragable, CGPoint) -> Bool), buttonActions: DragableButtonActions? = nil, label: @escaping LabelBuilder) {
        self.dragableObject = object
        self.onDragObject = onDragObject
        self.onDropObject = onDropObject
        self.buttonActions = buttonActions
        self.label = label
    }
    
    public typealias Action = () -> Void
    public typealias DragAction = (DragGesture.Value) -> Void
    public typealias LabelBuilder = (_ isPressed: Bool) -> Label
    
    public var body: some View {
        ScrollViewGestureButton(
            offset: $dragOffset,
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
                
            },
            label: label
        )
    }
}

@available(iOS 14, *)
public extension DragableButton {
    public init(label: @escaping LabelBuilder, buttonActions: DragableButtonActions? = nil) {
        print("init Button")
        self.dragableObject = nil
        self.label = label
        self.onDragged = defaultOnDragged
        self.onDropped = defaultOnDropped
        self.buttonActions = buttonActions
    }
    
    private func defaultOnDragged(_: CGPoint) -> DragState { .unknown }
    private func defaultOnDropped(_: CGPoint) -> Bool { false }
}
