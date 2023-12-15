
import SwiftUI

public protocol Dragable { }

struct DragableObject: ViewModifier {
    @State private var dragOffset = CGSize.zero
    @State private var dragState = DragState.none
    @State private var successfulDrop: Bool = false
    let dragableObject: Dragable?
    
    var isDragAvaliableAfterLongPress: Bool = false
    
    var onDragObject: ((Dragable, CGPoint) -> DragState)? = nil
    var onDragged: ((CGPoint) -> DragState)? = nil
    var onDropObject: ((Dragable, CGPoint) -> Bool)? = nil
    var onDropped: ((CGPoint) -> Bool)? = nil
    
    init(isDragAvaliableAfterLongPress: Bool = false, onDragged: @escaping ((CGPoint) -> DragState), onDropped: @escaping ((CGPoint) -> Bool)) {
        self.dragableObject = nil
        self.isDragAvaliableAfterLongPress = isDragAvaliableAfterLongPress
        self.onDragged = onDragged
        self.onDropped = onDropped
    }
    
    init(object: Dragable, isDragAvaliableAfterLongPress: Bool = false, onDragged: @escaping ((CGPoint) -> DragState), onDropObject: @escaping ((Dragable, CGPoint) -> Bool)) {
        self.dragableObject = object
        self.isDragAvaliableAfterLongPress = isDragAvaliableAfterLongPress
        self.onDragged = onDragged
        self.onDropObject = onDropObject
    }
    
    init(object: Dragable, isDragAvaliableAfterLongPress: Bool = false, onDragObject: @escaping ((Dragable, CGPoint) -> DragState), onDropped: @escaping ((CGPoint) -> Bool)) {
        self.dragableObject = object
        self.isDragAvaliableAfterLongPress = isDragAvaliableAfterLongPress
        self.onDragObject = onDragObject
        self.onDropped = onDropped
    }
    
    init(object: Dragable, isDragAvaliableAfterLongPress: Bool = false, onDragObject: @escaping ((Dragable, CGPoint) -> DragState), onDropObject: @escaping ((Dragable, CGPoint) -> Bool)) {
        self.dragableObject = object
        self.isDragAvaliableAfterLongPress = isDragAvaliableAfterLongPress
        self.onDragObject = onDragObject
        self.onDropObject = onDropObject
    }
    
    
    func body(content: Content) -> some View {
        content
            .shadow(color: dragColor, radius: DrawingConstants.shadowRadius)
            .offset(x: dragOffset.width, y: dragOffset.height)
            .gesture(
                SimultaneousGesture(
                    DragGesture(coordinateSpace: .global)
                        .onChanged { gesture in
                            if dragState == .unavaliable || (isDragAvaliableAfterLongPress && dragState == .none) {
                                dragState = .unavaliable
                                return
                            }
                            self.dragOffset = CGSize(
                                width: gesture.translation.width,
                                height: gesture.translation.height)
                            withAnimation(.linear(duration: DrawingConstants.dragStateOnChangedTransitionDuration)) {
                                self.dragState = self.onDragged != nil ? self.onDragged!(gesture.location) : self.onDragObject!(dragableObject!, gesture.location)
                            }
                            
                        }
                        .onEnded { gesture in
                            if dragState == .unavaliable { return }
                            successfulDrop = self.onDropped != nil ? self.onDropped!(gesture.location) : self.onDropObject!(dragableObject!, gesture.location)
                            withAnimation(.linear(duration: DrawingConstants.dragStateOnEndedTransitionDuration)) {
                                self.dragState = .none
                            }
                            withAnimation(successfulDrop ? .none : .linear) {
                                self.dragOffset = .zero
                            }
                        },
                        SimultaneousGesture(
                            LongPressGesture()
                                .onEnded { pressValue in
                                    if dragState == .none {
                                        dragState = .unknown
                                    }
                                },
                            DragGesture(minimumDistance: 0)
                                .onEnded { _ in
                                    dragState = .none
                                }
                        )
                    )
                )
    }
    
    private var dragColor: Color {
        switch dragState {
        case .none:
            return DrawingConstants.dragColorNone
        case .unknown:
            return DrawingConstants.dragColorUnknown
        case .accepted:
            return DrawingConstants.dragColorAccepted
        case .rejected:
            return DrawingConstants.dragColorUnaccepted
        case .unavaliable:
            return DrawingConstants.dragColorNone
        }
    }
}

private struct DrawingConstants {
    static let shadowRadius: CGFloat = 10
    static let dragStateOnChangedTransitionDuration: Double = 0.25
    static let dragStateOnEndedTransitionDuration: Double = 2
    
    static let dragColorNone = Color.clear
    static let dragColorUnknown = Color.blue
    static let dragColorAccepted = Color.green
    static let dragColorUnaccepted = Color.red
}

extension DragableObject {
    init(isDragAvaliableAfterLongPress: Bool = false) {
        self.dragableObject = nil
        self.isDragAvaliableAfterLongPress = isDragAvaliableAfterLongPress
        self.onDragged = defaultOnDragged
        self.onDropped = defaultOnDropped
    }
    
    private func defaultOnDragged(_: CGPoint) -> DragState { .unknown }
    private func defaultOnDropped(_: CGPoint) -> Bool { false }
}

extension View {
    public func dragable(isDragAvaliableAfterLongPress: Bool = false, onDragged: @escaping (CGPoint) -> DragState, onDropped: @escaping (CGPoint) -> Bool) -> some View {
        modifier(DragableObject(isDragAvaliableAfterLongPress: isDragAvaliableAfterLongPress, onDragged: onDragged, onDropped: onDropped))
    }
    
    public func dragable(object: Dragable, isDragAvaliableAfterLongPress: Bool = false, onDragObject: @escaping (Dragable, CGPoint) -> DragState, onDropped: @escaping (CGPoint) -> Bool) -> some View {
        modifier(DragableObject(object: object, isDragAvaliableAfterLongPress: isDragAvaliableAfterLongPress, onDragObject: onDragObject, onDropped: onDropped))
    }
    
    public func dragable(object: Dragable, isDragAvaliableAfterLongPress: Bool = false, onDragged: @escaping (CGPoint) -> DragState, onDropObject: @escaping (Dragable, CGPoint) -> Bool) -> some View {
        modifier(DragableObject(object: object, isDragAvaliableAfterLongPress: isDragAvaliableAfterLongPress, onDragged: onDragged, onDropObject: onDropObject))
    }
    
    public func dragable(object: Dragable, isDragAvaliableAfterLongPress: Bool = false, onDragObject: @escaping (Dragable, CGPoint) -> DragState, onDropObject: @escaping (Dragable, CGPoint) -> Bool) -> some View {
        modifier(DragableObject(object: object, isDragAvaliableAfterLongPress: isDragAvaliableAfterLongPress, onDragObject: onDragObject, onDropObject: onDropObject))
    }
    
    public func dragable(isDragAvaliableAfterLongPress: Bool = false) -> some View {
        modifier(DragableObject(isDragAvaliableAfterLongPress: isDragAvaliableAfterLongPress))
    }
}
