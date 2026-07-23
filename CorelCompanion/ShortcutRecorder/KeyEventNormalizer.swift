import AppKit

enum KeyEventNormalizer {
    static func shortcut(from event: NSEvent) -> ShortcutDefinition? {
        guard let key = key(from: event) else { return nil }
        var modifiers = Set<ShortcutModifier>()
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if flags.contains(.control) { modifiers.insert(.control) }
        if flags.contains(.command) { modifiers.insert(.command) }
        if flags.contains(.option) { modifiers.insert(.option) }
        if flags.contains(.shift) { modifiers.insert(.shift) }
        if key == .character("+") {
            // Shift is a physical requirement for '+' on common Mac layouts,
            // but Corel shortcut tables treat '+' as the logical key itself.
            modifiers.remove(.shift)
        }
        return ShortcutDefinition(modifiers: modifiers, key: key)
    }

    private static let ansiCharacters: [UInt16: String] = [
        0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X", 8: "C", 9: "V",
        11: "B", 12: "Q", 13: "W", 14: "E", 15: "R", 16: "Y", 17: "T",
        18: "1", 19: "2", 20: "3", 21: "4", 22: "6", 23: "5", 25: "9", 26: "7", 28: "8", 29: "0",
        31: "O", 32: "U", 34: "I", 35: "P", 37: "L", 38: "J", 40: "K", 45: "N", 46: "M"
    ]

    static func key(forKeyCode keyCode: UInt16, shifted: Bool = false) -> ShortcutKey? {
        if let character = ansiCharacters[keyCode] { return .character(character) }
        switch keyCode {
        case 24: return .character(shifted ? "+" : "=")
        case 27: return .character("-")
        case 30: return .character("]")
        case 33: return .character("[")
        case 41: return .character(";")
        case 43: return .character(",")
        case 44: return .character("/")
        case 47: return .character(".")
        default: return nil
        }
    }

    private static func key(from event: NSEvent) -> ShortcutKey? {
        if let key = key(forKeyCode: event.keyCode, shifted: event.modifierFlags.contains(.shift)) { return key }
        switch event.keyCode {
        case 36, 76: return .enter
        case 48: return .tab
        case 49: return .space
        case 51, 117: return .delete
        case 53: return .escape
        case 115: return .home
        case 119: return .end
        case 116: return .pageUp
        case 121: return .pageDown
        case 123: return .arrowLeft
        case 124: return .arrowRight
        case 125: return .arrowDown
        case 126: return .arrowUp
        case 122: return .function(1)
        case 120: return .function(2)
        case 99: return .function(3)
        case 118: return .function(4)
        case 96: return .function(5)
        case 97: return .function(6)
        case 98: return .function(7)
        case 100: return .function(8)
        case 101: return .function(9)
        case 109: return .function(10)
        case 103: return .function(11)
        case 111: return .function(12)
        case 105: return .function(13)
        case 107: return .function(14)
        case 113: return .function(15)
        case 106: return .function(16)
        case 64: return .function(17)
        case 79: return .function(18)
        case 80: return .function(19)
        case 90: return .function(20)
        default:
            return nil
        }
    }
}
