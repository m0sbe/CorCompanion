import SwiftUI

struct ShortcutRecorderView: NSViewRepresentable {
    @Binding var shortcut: ShortcutDefinition?
    @Binding var isRecording: Bool
    let language: AppLanguage

    func makeNSView(context: Context) -> ShortcutRecorderNSView {
        let view = ShortcutRecorderNSView()
        view.onShortcutChanged = { shortcut = $0 }
        view.onRecordingChanged = { isRecording = $0 }
        return view
    }

    func updateNSView(_ nsView: ShortcutRecorderNSView, context: Context) {
        nsView.shortcut = shortcut
        nsView.isRecording = isRecording
        nsView.language = language
        if isRecording, nsView.window?.firstResponder !== nsView {
            nsView.window?.makeFirstResponder(nsView)
        }
    }
}
