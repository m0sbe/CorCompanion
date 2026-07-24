import AppKit
import ApplicationServices

struct AccessibilityPermissionManager {
    var hasAccessibilityAccess: Bool { AXIsProcessTrusted() }
    var isTrusted: Bool { hasAccessibilityAccess }

    @discardableResult
    func requestIfNeeded() -> Bool {
        if !hasAccessibilityAccess {
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
            _ = AXIsProcessTrustedWithOptions(options)
        }
        return isTrusted
    }

    func openSystemSettings() {
        guard let url = URL(
            string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        ) else { return }
        NSWorkspace.shared.open(url)
    }

    func missingPermissionDescription() -> String? {
        hasAccessibilityAccess ? nil : "Требуется разрешение «Универсальный доступ»."
    }
}
