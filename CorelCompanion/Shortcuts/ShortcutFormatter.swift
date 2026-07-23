import Foundation

enum ShortcutFormatter {
    static func windows(_ shortcut: ShortcutDefinition?) -> String {
        guard let shortcut else { return "—" }
        let order: [ShortcutModifier] = [.control, .command, .option, .shift]
        let names: [ShortcutModifier: String] = [.control: "Ctrl", .command: "Win", .option: "Alt", .shift: "Shift"]
        return (order.filter(shortcut.modifiers.contains).compactMap { names[$0] } + [keyName(shortcut.key)]).joined(separator: " + ")
    }

    static func macOS(_ shortcut: ShortcutDefinition?) -> String {
        guard let shortcut else { return "—" }
        let order: [ShortcutModifier] = [.control, .option, .shift, .command]
        let symbols: [ShortcutModifier: String] = [.control: "⌃", .option: "⌥", .shift: "⇧", .command: "⌘"]
        return order.filter(shortcut.modifiers.contains).compactMap { symbols[$0] }.joined() + keyName(shortcut.key)
    }

    static func recorder(_ shortcut: ShortcutDefinition?) -> String {
        macOS(shortcut)
    }

    private static func keyName(_ key: ShortcutKey) -> String {
        switch key {
        case let .character(value): return value.uppercased()
        case .arrowUp: return "↑"
        case .arrowDown: return "↓"
        case .arrowLeft: return "←"
        case .arrowRight: return "→"
        case .space: return "Space"
        case .tab: return "Tab"
        case .enter: return "Return"
        case .delete: return "Delete"
        case .escape: return "Esc"
        case .home: return "Home"
        case .end: return "End"
        case .pageUp: return "Page Up"
        case .pageDown: return "Page Down"
        case let .function(number): return "F\(number)"
        }
    }
}
