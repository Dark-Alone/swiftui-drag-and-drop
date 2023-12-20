import Foundation

/**
 This struct can be used to configure default values for the
 ``GestureButton`` and ``ScrollViewGestureButton`` views.
 */
public struct GestureButtonDefaults {

    /// The max time between two taps for them to count as a double tap, by default `0.2`.
    public static var doubleTapTimeout = 0.2

    /// The time it takes for a press to count as a long press, by default `1.0`.
    public static var longPressDelay = 1.0

    /// The time it takes for a press to count as a repeat trigger, by default `1.0`.
    public static var repeatDelay = 1.0
}
