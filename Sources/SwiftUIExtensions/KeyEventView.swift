
import SwiftUI

#if os(iOS) || os(watchOS) || os(tvOS)
fileprivate typealias Representable = UIViewRepresentable
#else
fileprivate typealias Representable = NSViewRepresentable
#endif

// Our SwiftUI wrapper view
 struct KeyEventView: Representable {
	// The types of touches users want to be notified about


	// A closure to call when touch data has arrived
	var onKeyDown: ((UInt16) -> Void)?
	var onKeyUp: ((UInt16) -> Void)?

#if os(iOS) || os(watchOS) || os(tvOS)
	 typealias ViewType = UIView
	 func makeUIView(context: Context) -> InternalView{
		// Create the underlying view, passing in our config
		makeView()
	}
	 func updateUIView(_ uiView: InternalView, context: Context){}
#else
	 typealias ViewType = NSView
	 func makeNSView(context: Context) -> InternalView {
		makeView()

	}
	 func updateNSView(_ nsView: InternalView, context: Context) {

	}
#endif
	private func makeView() -> InternalView {
		let view = InternalView()
		view.onKeyUp = onKeyUp
		view.onKeyDown = onKeyDown


		return view
	}

	// The internal view responsible for catching tap events
	 class InternalView: ViewType {
		// Internal copies of our settings
		var onKeyDown: ((UInt16) -> Void)?
		var onKeyUp: ((UInt16) -> Void)?
		 override var acceptsFirstResponder: Bool { true }


		// triggered when a keyEvent starts
#if os(iOS) || os(watchOS) || os(tvOS)
		// MARK: todo implment ios overrides
		override func pressesBegan(_ presses: Set<UIPress>, with event: UIPRessEvent?){
			if onKeyDown != nil {
				for press in presses {
					if let key = press.key {
						
					}
				}
			} else {
				super.pressesBegan(presses, with: event)
			}
		}

#else
		 override func keyDown(with event: NSEvent) {
			 if onKeyDown == nil {
				 super.keyDown(with: event)
			 } else{
				 if !event.isARepeat{
					 onKeyDown!(event.keyCode)
				 }
			 }
		}
		 override func keyUp(with event: NSEvent) {
			 if onKeyUp == nil {
				 super.keyUp(with: event)
			 } else {
				 if !event.isARepeat {
					 onKeyUp!(event.keyCode)
				 }
			 }
		}
#endif


	}

}


struct KeyEventModifier: ViewModifier{
	let onKeyDown: ((UInt16) -> Void)?
	let onKeyUp: ((UInt16) -> Void)?
	func body(content: Content) -> some View {
		content
			.overlay{
				KeyEventView(onKeyDown: onKeyDown, onKeyUp: onKeyUp)
			}
	}


}
extension View {
	public func onKeyDownEvent(action: @escaping (UInt16) -> Void) -> some View{
		self.modifier(KeyEventModifier( onKeyDown: action, onKeyUp: nil))
	}
	public func onKeyUpEvent(action: @escaping (UInt16) -> Void) -> some View{
		self.modifier(KeyEventModifier(onKeyDown: nil, onKeyUp: action))
	}
	public func onKeyChangeEvent(action: @escaping (UInt16) -> Void) -> some View{
		self.modifier(KeyEventModifier(onKeyDown: action, onKeyUp: action))
	}
}
