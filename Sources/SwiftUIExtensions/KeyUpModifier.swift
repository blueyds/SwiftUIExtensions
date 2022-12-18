import SwiftUI
//import KeyboardShortcuts

public struct KeyUpModifier: ViewModifier {
    public var onKeyUp: (UIKey)-> Void
    public init(_ keyUpCallback: @escaping (UIKey)-> Void){
        onKeyUp = keyUpCallback
    }
    public func body(content: Content) -> some View {
        content
            .background(KeyUpRepresentable(onKeyUp: onKeyUp))
    }
}

private struct KeyUpRepresentable: UIViewRepresentable {
    var onKeyUp: (UIKey)-> Void
    func makeUIView(context: Context) -> some UIView {
        let view = KeyUpView()
        view.onKeyUp = self.onKeyUp
        view.becomeFirstResponder()
        //        print("\(view.isFirstResponder)")
        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) { 
        uiView.becomeFirstResponder()
    }
}
private class KeyUpView: UIView {
    var onKeyUp: ((UIKey) -> Void)!
    override var canBecomeFirstResponder: Bool { true }
    //    init(_ keyDownCallback: @escaping (UIKey)-> Void) {
    //        self.onKeyDown = keyDownCallback
    //        super.init()
    //    }
    //
    //    required init?(coder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        print("Override")
        presses.forEach(){
            if let key = $0.key {
                onKeyUp(key)
            }
        }
        super.pressesEnded(presses, with: event)
    }
}



