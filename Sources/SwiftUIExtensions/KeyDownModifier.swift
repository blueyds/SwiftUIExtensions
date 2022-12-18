import SwiftUI
//import KeyboardShortcuts

public struct KeyDownModifier: ViewModifier {
    public var onKeyDown: (UIKey)-> Void
    public init(_ keyDownCallback: @escaping (UIKey)-> Void){
        onKeyDown = keyDownCallback
    }
    public func body(content: Content) -> some View {
        content
            .background(KeyDownRepresentable(onKeyDown: onKeyDown))
    }
}

private struct KeyDownRepresentable: UIViewRepresentable {
    var onKeyDown: (UIKey)-> Void
    func makeUIView(context: Context) -> some UIView {
        let view = KeyDownView()
        view.onKeyDown = self.onKeyDown
        view.becomeFirstResponder()
//        print("\(view.isFirstResponder)")
        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) { 
        uiView.becomeFirstResponder()
    }
}
private class KeyDownView: UIView {
    var onKeyDown: ((UIKey) -> Void)!
    override var canBecomeFirstResponder: Bool { true }
//    init(_ keyDownCallback: @escaping (UIKey)-> Void) {
//        self.onKeyDown = keyDownCallback
//        super.init()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        print("Override")
        presses.forEach(){
            if let key = $0.key {
                onKeyDown(key)
            }
        }
        super.pressesBegan(presses, with: event)
    }
}



