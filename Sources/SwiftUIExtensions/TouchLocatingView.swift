
import SwiftUI

#if os(iOS) || os(watchOS) || os(tvOS)
file typealias Representable = UIViewRepresentable
#else
file typealias Representable = NSViewRepresentable
#endif

// Our SwiftUI wrapper view
public struct TouchLocatingView: Representable {
	// The types of touches users want to be notified about
	public struct TouchType: OptionSet{
		let rawValue: Int

		public static let started = TouchType(rawValue: 1 << 0)
		public static let moved = TouchType(rawValue: 1 << 1)
		public static let ended = TouchType(rawValue: 1 << 2)
		public static let all: TouchType = [.started, .moved, .ended]
	}

	// A closure to call when touch data has arrived
	var onUpdate: (CGPoint) -> Void

	// The list of touch types to notified of
	var types = TouchType.all

	// Whether touch information should continue after the user's finger
	// has left the view
	var limitToBounds = true

#if os(iOS) || os(watchOS) || os(tvOS)
	typealias ViewType = UIView
	func makeUIView(context: Context) -> TouchLocatingInternalView {
		// Create the underlying view, passing in our config
		makeView()
	}
	func updateUIView(_ uiView: TouchLocatingInternalView, context: Context){}
#else
	typealias ViewType = NSView
	func makeNSView(context: Context) -> TouchLocatingInternalView {
		makeView()
	}
	func updateNSView(_ nsView: TouchLocatingInternalView, context: Context) {

	}
#endif
	private func makeView() -> TouchLocatingInternalView {
		let view = TouchLocatingInternalView()
		view.onUpdate = onUpdate
		view.touchTypes = types
		view.limitToBounds = limitToBounds
		return view
	}

	// The internal view responsible for catching tap events
	class TouchLocatingInternalView: ViewType {
		// Internal copies of our settings
		var onUpdate: ((CGPoint) -> Void)?
		var touchTypes: TouchLocatingView.TouchType = .all
		var limitToBounds = true

		// Our main initializer
//		override init(frame: CGRect) {
//			super.init(frame: frame)
//			isUserInteractionEnabled
//		}

		// triggered when a touch starts
#if os(iOS) || os(watchOS) || os(tvOS)
		// MARK: todo implment ios overrides

#else
		override func touchesBegan(with event: NSEvent) {
			guard let touch = event.touches(matching: .began, in: self).first else { return}
			let location = touch.location(in: self)
			send(location, forEvent: .started)
		}
		override func touchesMoved(with event: NSEvent) {
			guard let touch = event.touches(matching: .moved, in: self).first else { return}
			let location = touch.location(in: self)
			send(location, forEvent: .moved)
		}
		override func touchesEnded(with event: NSEvent) {
			guard let touch = event.touches(matching: .ended, in: self).first else { return}
			let location = touch.location(in: self)
			send(location, forEvent: .ended)
		}
#endif
		private func send(_ location: CGPoint, forEvent event: TouchLocatingView.TouchType){
			guard touchTypes.contains(event) else { return }
			if limitToBounds == false ||
				bounds.contains(location){
				onUpdate?(CGPoint(x: round(location.x), y: round(location.y)))
			}
		}


	}

}

struct TouchLocater: ViewModifier{
	var type: TouchLocatingView.TouchType = .all
	var limitToBounds = true
	let perform: (CGPoint) -> Void

	func body(content: Content) -> some View {
		content
			.overlay{
				TouchLocatingView(onUpdate: perform, types: type, limitToBounds: limitToBounds)
			}
	}
}
extension View {
	public func onTouch(type: TouchLocatingView.TouchType = .all, limitToBounds: Bool = true, perform: @escaping (CGPoint) -> Void) -> some View {
	self.modifier(TouchLocater(type: type, limitToBounds: limitToBounds, perform: perform))
	}
}
