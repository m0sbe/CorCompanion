import CoreGraphics
import Foundation

final class MouseEventTap {
    typealias Handler = (CGEventType, CGEvent) -> Bool
    private var tap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var handler: Handler?

    var isRunning: Bool { tap != nil }

    var isHealthy: Bool {
        guard let tap, CFMachPortIsValid(tap) else { return false }
        return CGEvent.tapIsEnabled(tap: tap)
    }

    func start(handler: @escaping Handler) -> Bool {
        stop()
        self.handler = handler
        let mask = [CGEventType.otherMouseDown, .otherMouseDragged, .otherMouseUp]
            .reduce(CGEventMask(0)) { $0 | (CGEventMask(1) << $1.rawValue) }

        let callback: CGEventTapCallBack = { _, type, event, userInfo in
            guard let userInfo else { return Unmanaged.passUnretained(event) }
            let owner = Unmanaged<MouseEventTap>.fromOpaque(userInfo).takeUnretainedValue()
            if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                if let tap = owner.tap, CFMachPortIsValid(tap) {
                    CGEvent.tapEnable(tap: tap, enable: true)
                }
                return Unmanaged.passUnretained(event)
            }
            guard event.getIntegerValueField(.mouseEventButtonNumber) == 2 else {
                return Unmanaged.passUnretained(event)
            }
            let consume = owner.handler?(type, event) ?? false
            return consume ? nil : Unmanaged.passUnretained(event)
        }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            self.handler = nil
            return false
        }
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        self.tap = tap
        runLoopSource = source
        return true
    }

    func stop() {
        if let tap { CGEvent.tapEnable(tap: tap, enable: false) }
        if let runLoopSource { CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes) }
        tap = nil
        runLoopSource = nil
        handler = nil
    }

    deinit { stop() }
}
