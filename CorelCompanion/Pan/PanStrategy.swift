import CoreGraphics

protocol PanStrategy: AnyObject {
    func begin(at location: CGPoint)
    func drag(to location: CGPoint)
    func end(at location: CGPoint)
    func cancel()
}

/// Selects CorelDRAW's documented Pan tool (H), converts the middle-button
/// gesture into a primary-button drag, then returns to the Pick tool (V).
/// This uses only public event APIs and does not inject into CorelDRAW.
final class CorelPanToolStrategy: PanStrategy {
    private var isPanning = false
    private let source = CGEventSource(stateID: .combinedSessionState)

    func begin(at location: CGPoint) {
        guard !isPanning else { return }
        isPanning = true
        postShortcut(keyCode: 4) // H — documented CorelDRAW Pan tool
        postMouse(type: .leftMouseDown, location: location)
    }

    func drag(to location: CGPoint) {
        guard isPanning else { return }
        postMouse(type: .leftMouseDragged, location: location)
    }

    func end(at location: CGPoint) {
        guard isPanning else { return }
        postMouse(type: .leftMouseUp, location: location)
        isPanning = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) { [weak self] in
            // CorelDRAW 2026 toggles from Pan back to the previously active
            // toolbox state when Space is pressed after the gesture.
            self?.postShortcut(keyCode: 49)
        }
    }

    func cancel() {
        guard isPanning else { return }
        let location = CGEvent(source: nil)?.location ?? .zero
        end(at: location)
    }

    private func postMouse(type: CGEventType, location: CGPoint) {
        let button: CGMouseButton = .left
        CGEvent(mouseEventSource: source, mouseType: type, mouseCursorPosition: location, mouseButton: button)?.post(tap: .cghidEventTap)
    }

    private func postShortcut(keyCode: CGKeyCode) {
        CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)?.post(tap: .cghidEventTap)
        CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)?.post(tap: .cghidEventTap)
    }
}
