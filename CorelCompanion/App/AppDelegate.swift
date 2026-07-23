import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var applicationState: ApplicationState?
    private var statusController: StatusItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let repository = ShortcutRepository()
        let monitor = ActiveApplicationMonitor()
        let panController = PanController(
            permissionManager: AccessibilityPermissionManager(),
            eventTap: MouseEventTap()
        )
        let state = ApplicationState(
            repository: repository,
            applicationMonitor: monitor,
            panController: panController
        )
        applicationState = state
        statusController = StatusItemController(state: state)
        monitor.start()
        showFirstLaunchMessageIfNeeded(language: state.language)
    }

    func applicationWillTerminate(_ notification: Notification) {
        applicationState?.shutdown()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        applicationState?.refreshPermissions()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        statusController?.showPopover()
        return true
    }

    private func showFirstLaunchMessageIfNeeded(language: AppLanguage) {
        let key = "didShowFirstLaunchMessage"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)

        let alert = NSAlert()
        alert.messageText = AppStrings.firstLaunchTitle(language)
        alert.informativeText = AppStrings.firstLaunchMessage(language)
        alert.addButton(withTitle: AppStrings.understood(language))
        alert.runModal()
    }
}
