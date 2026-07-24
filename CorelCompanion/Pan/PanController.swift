import AppKit
import Combine
import CoreGraphics

@MainActor
final class PanController: ObservableObject {
    @Published private(set) var status: PanStatus = .inactive
    private let permissionManager: AccessibilityPermissionManager
    private let eventTap: MouseEventTap
    private let strategy: PanStrategy
    private var userEnabled = false
    private var corelActive = false
    private var healthTimer: Timer?

    init(permissionManager: AccessibilityPermissionManager, eventTap: MouseEventTap, strategy: PanStrategy = CorelPanToolStrategy()) {
        self.permissionManager = permissionManager
        self.eventTap = eventTap
        self.strategy = strategy
    }

    func setUserEnabled(_ enabled: Bool) {
        userEnabled = enabled
        if enabled, !permissionManager.requestIfNeeded() {
            status = permissionStatus
        }
        reconcile()
    }

    func setCorelActive(_ active: Bool) {
        corelActive = active
        reconcile()
    }

    /// TCC permissions can change while System Settings is frontmost.
    /// Reconcile when the user returns instead of requiring a toggle or relaunch.
    func refreshPermissions() {
        reconcile()
    }

    func requestPermissions() {
        _ = permissionManager.requestIfNeeded()
        if !permissionManager.isTrusted {
            permissionManager.openSystemSettings()
        }
        reconcile()
    }

    var needsPermissions: Bool {
        switch status {
        case .missingAccessibility: true
        default: false
        }
    }

    func shutdown() {
        stopHealthMonitor()
        strategy.cancel()
        eventTap.stop()
    }

    private func reconcile() {
        guard userEnabled else {
            stopHealthMonitor()
            strategy.cancel()
            eventTap.stop()
            status = .inactive
            return
        }
        guard permissionManager.isTrusted else {
            stopHealthMonitor()
            strategy.cancel()
            eventTap.stop()
            status = permissionStatus
            return
        }
        guard corelActive else {
            stopHealthMonitor()
            strategy.cancel()
            eventTap.stop()
            status = .waitingForCorel
            return
        }
        startHealthMonitor()
        if !eventTap.isHealthy {
            eventTap.stop()
            let started = eventTap.start { [weak self] type, event in
                guard let self, self.corelActive, self.userEnabled else { return false }
                switch type {
                case .otherMouseDown: self.strategy.begin(at: event.location)
                case .otherMouseDragged: self.strategy.drag(to: event.location)
                case .otherMouseUp: self.strategy.end(at: event.location)
                default: return false
                }
                return true
            }
            status = started ? .active : .eventTapFailed
        }
    }

    private func startHealthMonitor() {
        guard healthTimer == nil else { return }
        let timer = Timer(timeInterval: 5, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.reconcile() }
        }
        timer.tolerance = 1
        RunLoop.main.add(timer, forMode: .common)
        healthTimer = timer
    }

    private func stopHealthMonitor() {
        healthTimer?.invalidate()
        healthTimer = nil
    }

    private var permissionStatus: PanStatus {
        permissionManager.hasAccessibilityAccess ? .inactive : .missingAccessibility
    }
}

enum PanStatus {
    case inactive
    case missingAccessibility
    case waitingForCorel
    case active
    case eventTapFailed
}
