import Foundation

enum ShortcutCategory: String, Codable, CaseIterable {
    case file, edit, object, view, arrange, text, effects, window, tools
}

struct ShortcutEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let category: ShortcutCategory
    let titleRU: String
    let titleEN: String?
    let windowsShortcut: ShortcutDefinition?
    let macShortcut: ShortcutDefinition?
    let notes: String?
}
