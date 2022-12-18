import SwiftUI


extension View{

    public func onKeyEvent(_ perform: @escaping (UIPress)-> Void)-> some View{
        self.modifier(KeyEventModifier(perform))
    }
}

public struct KeyEventModifier: ViewModifier {
    public var action: (UIPress)-> Void
    public init(_ perform: @escaping (UIPress)-> Void){
        action = perform
    }
    public func body(content: Content) -> some View {
        content
            .background(KeyEventRepresentable(action: action))
    }
}

private struct KeyEventRepresentable: UIViewRepresentable {
    var action: (UIPress)-> Void
    func makeUIView(context: Context) -> some UIView {
        let view = KeyEventView()
        view.action = self.action
        view.becomeFirstResponder()
        //        print("\(view.isFirstResponder)")
        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) { 
        uiView.becomeFirstResponder()
    }
}
private class KeyEventView: UIView {
    var action: ((UIPress) -> Void)!
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
            if $0.key != nil {
                action($0)
            }
        }
        super.pressesBegan(presses, with: event)
    }
    override func pressesChanged(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        presses.forEach(){
            if $0.key != nil {
                action($0)
            }
        }
        super.pressesChanged(presses, with: event)
    }
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        presses.forEach(){
            if $0.key != nil {
                action($0)
            }
        }
        super.pressesEnded(presses, with: event)
    }
}



