import AppKit
import Combine

@MainActor
final class ActiveApplicationMonitor: ObservableObject {
    @Published private(set) var isCorelRunning = false
    @Published private(set) var isCorelActive = false
    @Published private(set) var shouldShowStatusItem = false
    private var observers: [NSObjectProtocol] = []

    func start() {
        guard observers.isEmpty else { return }
        let center = NSWorkspace.shared.notificationCenter
        observers = [
            center.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.refresh() }
            },
            center.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.refresh() }
            },
            center.addObserver(forName: NSWorkspace.didTerminateApplicationNotification, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.refresh() }
            }
        ]
        refresh()
    }

    func stop() {
        let center = NSWorkspace.shared.notificationCenter
        observers.forEach(center.removeObserver)
        observers.removeAll()
    }

    private func refresh() {
        isCorelRunning = NSWorkspace.shared.runningApplications.contains {
            CorelApplicationMatcher.matches(bundleIdentifier: $0.bundleIdentifier)
        }
        let frontmostIdentifier = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        let ownIdentifier = Bundle.main.bundleIdentifier
        if frontmostIdentifier == ownIdentifier {
            // Keep the menu extra visible while its own transient popover has focus,
            // but never leave the global mouse tap active over our UI.
            isCorelActive = false
            return
        }
        let corelIsFrontmost = CorelApplicationMatcher.matches(bundleIdentifier: frontmostIdentifier)
        isCorelActive = corelIsFrontmost
        shouldShowStatusItem = corelIsFrontmost
    }
}
