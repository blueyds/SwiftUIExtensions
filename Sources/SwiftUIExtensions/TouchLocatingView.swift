
import SwiftUI

#if os(iOS) || os(watchOS) || os(tvOS)
fileprivate typealias Representable = UIViewRepresentable
#else
fileprivate typealias Representable = NSViewRepresentable
#endif
public struct TouchLocatingTouchType: OptionSet{
	public let rawValue: Int
	public init(rawValue: Int){
		self.rawValue = rawValue
	}

	public static let started = TouchLocatingTouchType(rawValue: 1 << 0)
	public static let moved = TouchLocatingTouchType(rawValue: 1 << 1)
	public static let ended = TouchLocatingTouchType(rawValue: 1 << 2)
	public static let all: TouchLocatingTouchType = [.started, .moved, .ended]
}
// Our SwiftUI wrapper view
struct TouchLocatingView: Representable {
	// The types of touches users want to be notified about


	// A closure to call when touch data has arrived
	var onUpdate: (CGPoint) -> Void

	// The list of touch types to notified of
	var types = TouchLocatingTouchType.all

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
		var touchTypes: TouchLocatingTouchType = .all
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
		private func send(_ location: CGPoint, forEvent event: TouchLocatingTouchType){
			guard touchTypes.contains(event) else { return }
			if limitToBounds == false ||
				bounds.contains(location){
				onUpdate?(CGPoint(x: round(location.x), y: round(location.y)))
			}
		}


	}

}

struct TouchLocater: ViewModifier{
	var type: TouchLocatingTouchType = .all
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
	public func onTouch(type: TouchLocatingTouchType = .all, limitToBounds: Bool = true, perform: @escaping (CGPoint) -> Void) -> some View {
	self.modifier(TouchLocater(type: type, limitToBounds: limitToBounds, perform: perform))
	}
}
