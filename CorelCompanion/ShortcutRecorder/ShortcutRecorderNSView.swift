import AppKit

final class ShortcutRecorderNSView: NSView {
    var isRecording = false {
        didSet {
            updateEventMonitor()
            updateAppearance()
        }
    }
    var shortcut: ShortcutDefinition? { didSet { updateAppearance() } }
    var language: AppLanguage = .ru { didSet { updateAppearance() } }
    var onShortcutChanged: ((ShortcutDefinition?) -> Void)?
    var onRecordingChanged: ((Bool) -> Void)?
    private let label = NSTextField(labelWithString: "")
    private var eventMonitor: Any?

    override var acceptsFirstResponder: Bool { true }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.cornerRadius = 6
        layer?.borderWidth = 1.5
        label.alignment = .center
        label.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        updateAppearance()
    }

    required init?(coder: NSCoder) { nil }

    deinit {
        if let eventMonitor { NSEvent.removeMonitor(eventMonitor) }
    }

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        isRecording = true
        onRecordingChanged?(true)
    }

    override func keyDown(with event: NSEvent) {
        guard isRecording else { return }
        handleRecordedEvent(event)
    }

    private func handleRecordedEvent(_ event: NSEvent) {
        if event.keyCode == 53 {
            isRecording = false
            onRecordingChanged?(false)
            return
        }
        if event.keyCode == 51 || event.keyCode == 117 {
            shortcut = nil
            onShortcutChanged?(nil)
            return
        }
        guard let normalized = KeyEventNormalizer.shortcut(from: event) else {
            NSSound.beep()
            return
        }
        shortcut = normalized
        isRecording = false
        onShortcutChanged?(normalized)
        onRecordingChanged?(false)
    }

    private func updateEventMonitor() {
        if isRecording, eventMonitor == nil {
            eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard let self, self.isRecording else { return event }
                self.handleRecordedEvent(event)
                return nil
            }
        } else if !isRecording, let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
    }

    private func updateAppearance() {
        label.stringValue = isRecording ? AppStrings.pressShortcut(language) : ShortcutFormatter.recorder(shortcut)
        label.textColor = .corelAccent
        layer?.borderColor = NSColor.corelAccent.withAlphaComponent(isRecording ? 0.85 : 0.38).cgColor
        layer?.backgroundColor = NSColor.corelAccent.withAlphaComponent(isRecording ? 0.12 : 0.045).cgColor
    }
}
