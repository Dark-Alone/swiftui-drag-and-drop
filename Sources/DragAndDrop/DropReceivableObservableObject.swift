
import SwiftUI

public protocol DropReceivableObservableObject: ObservableObject {
    associatedtype DropReceivable: DropReceiver
    
    func setDropArea(_ dropArea: CGRect, on dropReceiver: DropReceivable)
}

@available(iOS 17, *)
public protocol DropReceivableObservable: Observation.Observable, AnyObject {
    associatedtype DropReceivable: DropReceiver
    
    func setDropArea(_ dropArea: CGRect, on dropReceiver: DropReceivable)
}
