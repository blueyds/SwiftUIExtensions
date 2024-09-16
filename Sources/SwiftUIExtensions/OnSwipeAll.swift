import SwiftUI

extension View{
    
public func onSwipeAll(
        onLeftSwipe: @escaping ()->Void, 
        onRightSwipe: @escaping ()->Void,
        onUpSwipe: @escaping ()->Void,
        onDownSwipe: @escaping ()->Void) -> some View{
            self.modifier(
                AllSwipeGesture(
                    leftAction: onLeftSwipe, 
                    rightAction: onRightSwipe,
                    upAction: onUpSwipe,
                    downAction: onDownSwipe)
            )
    }
}


public struct AllSwipeGesture: ViewModifier{
    var leftAction: ()->Void
    var rightAction: ()->Void
    var upAction: ()->Void
    var downAction: ()->Void
    public func body(content: Content) -> some View {
        content
            .gesture(DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if abs(value.translation.width) > abs(value.translation.height) {
                        if value.translation.width < 0 {   leftAction()} 
                        else { rightAction ()}
                    } else {
                        if value.translation.height > 0 { upAction()}
                        else { downAction() }
                    }
                }
            )
    }
}
