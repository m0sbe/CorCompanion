import AppKit
import ApplicationServices
import CoreGraphics

struct AccessibilityPermissionManager {
    var hasAccessibilityAccess: Bool { AXIsProcessTrusted() }
    var hasInputMonitoringAccess: Bool { CGPreflightListenEventAccess() }
    var isTrusted: Bool { hasAccessibilityAccess && hasInputMonitoringAccess }

    @discardableResult
    func requestIfNeeded() -> Bool {
        if !hasAccessibilityAccess {
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
            _ = AXIsProcessTrustedWithOptions(options)
        }
        if !hasInputMonitoringAccess {
            _ = CGRequestListenEventAccess()
        }
        return isTrusted
    }

    func openSystemSettings(preferInputMonitoring: Bool) {
        let pane = preferInputMonitoring ? "Privacy_ListenEvent" : "Privacy_Accessibility"
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?\(pane)") else { return }
        NSWorkspace.shared.open(url)
    }

    func missingPermissionDescription() -> String? {
        switch (hasAccessibilityAccess, hasInputMonitoringAccess) {
        case (false, false): return "Требуются «Универсальный доступ» и «Мониторинг ввода»."
        case (false, true): return "Требуется разрешение «Универсальный доступ»."
        case (true, false): return "Требуется разрешение «Мониторинг ввода»."
        case (true, true): return nil
        }
    }
}
