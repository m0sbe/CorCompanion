import AppKit
import Combine
import SwiftUI

@MainActor
final class StatusItemController: NSObject {
    private static let popoverSize = NSSize(width: 620, height: 578)
    private let state: ApplicationState
    private let popover = NSPopover()
    private var statusItem: NSStatusItem?
    private var cancellables = Set<AnyCancellable>()

    init(state: ApplicationState) {
        self.state = state
        super.init()
        popover.behavior = .transient
        popover.animates = false
        popover.contentSize = Self.popoverSize
        popover.contentViewController = NSHostingController(rootView: CompanionPopoverView(state: state))
        showStatusItem()
        observePanState()
    }

    private func showStatusItem() {
        guard statusItem == nil else { return }
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.image = statusImage(isPanEnabled: state.panEnabled)
            button.imagePosition = .imageOnly
            button.toolTip = "CorCompanion"
            button.target = self
            button.action = #selector(togglePopover(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        statusItem = item
    }

    private func statusImage(isPanEnabled: Bool) -> NSImage? {
        let resourceName = isPanEnabled ? "PanOn" : "PanOff"
        guard let url = ResourceBundle.current.url(forResource: resourceName, withExtension: "svg"),
              let image = NSImage(contentsOf: url) else {
            return NSImage(systemSymbolName: "command", accessibilityDescription: "CorCompanion")
        }
        image.size = NSSize(width: 20, height: 18.5)
        image.isTemplate = true
        return image
    }

    private func observePanState() {
        state.$panEnabled
            .removeDuplicates()
            .sink { [weak self] isEnabled in
                self?.statusItem?.button?.image = self?.statusImage(isPanEnabled: isEnabled)
            }
            .store(in: &cancellables)
    }

    func showPopover() {
        guard let button = statusItem?.button else { return }
        if !popover.isShown {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func togglePopover(_ sender: NSStatusBarButton) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            let menu = NSMenu()
            menu.addItem(withTitle: AppStrings.quit(state.language), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
            statusItem?.menu = menu
            sender.performClick(nil)
            statusItem?.menu = nil
            return
        }
        if popover.isShown { popover.performClose(sender) }
        else { showPopover() }
    }
}
