
import SwiftUI

#if os(iOS) || os(watchOS) || os(tvOS)
fileprivate typealias Representable = UIViewRepresentable
#else
fileprivate typealias Representable = NSViewRepresentable
#endif

// Our SwiftUI wrapper view
public struct KeyEventView: Representable {
	// The types of touches users want to be notified about


	// A closure to call when touch data has arrived
	var onKeyDown: ((UInt16) -> Void)?
	var onKeyUp: ((UInt16) -> Void)?

#if os(iOS) || os(watchOS) || os(tvOS)
	public typealias ViewType = UIView
	public func makeUIView(context: Context) -> InternalView{
		// Create the underlying view, passing in our config
		makeView()
	}
	public func updateUIView(_ uiView: InternalView, context: Context){}
#else
	public typealias ViewType = NSView
	public func makeNSView(context: Context) -> InternalView {
		makeView()
	}
	public func updateNSView(_ nsView: InternalView, context: Context) {

	}
#endif
	private func makeView() -> InternalView {
		let view = InternalView()
		view.onKeyUp = onKeyUp
		view.onKeyDown = onKeyDown


		return view
	}

	// The internal view responsible for catching tap events
	public class InternalView: ViewType {
		// Internal copies of our settings
		var onKeyDown: ((UInt16) -> Void)?
		var onKeyUp: ((UInt16) -> Void)?


		// triggered when a keyEvent starts
#if os(iOS) || os(watchOS) || os(tvOS)
		// MARK: todo implment ios overrides
		override func pressesBegan(_ presses: Set<UIPress>, with event: UIPRessEvent?){
			for press in presses {
				if let key = press.key {
					let keyCode = Uint16(key.keyCode)
					send(keyCode, isUp: false)
				}
			}
		}

#else
		public override func keyDown(with event: NSEvent) {
			let keyCode = UInt16(event.keyCode)
			send(keyCode, isUp: false)
		}
		public override func keyUp(with event: NSEvent) {
			let keyCode = UInt16(event.keyCode)
			send(keyCode, isUp: true)
		}
#endif
		private func send(_ keyCode: UInt16, isUp: Bool){
			if isUp {
				if onKeyUp != nil { onKeyUp!(keyCode) }
			} else {
				if onKeyDown != nil { onKeyDown!(keyCode) }
			}
		}


	}

}

struct KeyEventModifier: ViewModifier{
	let onKeyDown: ((UInt16) -> Void)? = nil
	let onKeyUp: ((UInt16) -> Void)? = nil
	func body(content: Content) -> some View {
		content
			.overlay{
				KeyEventView(onKeyDown: onKeyDown, onKeyUp: onKeyUp, types: type)			}
	}
}
extension View {
	public func onKeyDownEvent(action: @escaping (UInt16) -> Void) -> some View{
		self.modifier(KeyEventModifier( onKeyDown: action))
	}
	public func onKeyUpEvent(action: @escaping (UInt16) -> Void) -> some View{
		self.modifier(KeyEventModifier(onKeyUp: action))
	}
	public func onKeyChangeEvent(action: @escaping (UInt16) -> Void) -> some View{
		self.modifier(KeyEventModifier(onKeyDown: action, onKeyUp: action))
	}
}
