import Foundation

enum ShortcutSearchEngine {
    struct RankedMatch {
        let entry: ShortcutEntry
        let distance: Double
    }

    static func search(_ query: String, in entries: [ShortcutEntry]) -> [ShortcutEntry] {
        let terms = normalize(query).split(separator: " ").map(String.init)
        guard !terms.isEmpty else { return entries }
        return entries.filter { entry in
            let haystack = normalize([
                entry.titleRU,
                entry.titleEN ?? "",
                ShortcutFormatter.windows(entry.windowsShortcut),
                ShortcutFormatter.macOS(entry.macShortcut),
                searchableModifierNames(entry.windowsShortcut),
                searchableModifierNames(entry.macShortcut)
            ].joined(separator: " "))
            return terms.allSatisfy(haystack.contains)
        }
    }

    static func matchingWindowsShortcut(_ shortcut: ShortcutDefinition, in entries: [ShortcutEntry]) -> [ShortcutEntry] {
        entries.filter { $0.windowsShortcut == shortcut }
    }

    static func matchingRecordedShortcut(_ shortcut: ShortcutDefinition, in entries: [ShortcutEntry]) -> [ShortcutEntry] {
        entries.filter { $0.windowsShortcut == shortcut || $0.macShortcut == shortcut }
    }

    static func rankedRecordedMatches(_ shortcut: ShortcutDefinition, in entries: [ShortcutEntry], limit: Int = 8) -> [RankedMatch] {
        return entries.compactMap { entry -> RankedMatch? in
            let distances = [entry.windowsShortcut, entry.macShortcut]
                .compactMap { $0 }
                .map { shortcutDistance(shortcut, $0) }
            guard let distance = distances.min(), distance <= 1.75 else { return nil }
            return RankedMatch(entry: entry, distance: distance)
        }
        .sorted {
            if $0.distance != $1.distance { return $0.distance < $1.distance }
            return $0.entry.titleRU.localizedCaseInsensitiveCompare($1.entry.titleRU) == .orderedAscending
        }
        .prefix(limit)
        .map { $0 }
    }

    static func rankedWindowsMatches(_ shortcut: ShortcutDefinition, in entries: [ShortcutEntry], limit: Int = 8) -> [RankedMatch] {
        let exact = entries.filter { $0.windowsShortcut == shortcut }
        if !exact.isEmpty { return exact.map { RankedMatch(entry: $0, distance: 0) } }

        return entries.compactMap { entry -> RankedMatch? in
            guard let candidate = entry.windowsShortcut else { return nil }
            let distance = shortcutDistance(shortcut, candidate)
            guard distance <= 1.75 else { return nil }
            return RankedMatch(entry: entry, distance: distance)
        }
        .sorted {
            if $0.distance != $1.distance { return $0.distance < $1.distance }
            return $0.entry.titleRU.localizedCaseInsensitiveCompare($1.entry.titleRU) == .orderedAscending
        }
        .prefix(limit)
        .map { $0 }
    }

    private static func shortcutDistance(_ lhs: ShortcutDefinition, _ rhs: ShortcutDefinition) -> Double {
        keyDistance(lhs.key, rhs.key) + modifierDistance(lhs.modifiers, rhs.modifiers)
    }

    private static func modifierDistance(_ lhs: Set<ShortcutModifier>, _ rhs: Set<ShortcutModifier>) -> Double {
        if lhs == rhs { return 0 }
        let differenceCount = lhs.symmetricDifference(rhs).count
        if lhs.isEmpty || rhs.isEmpty { return Double(differenceCount) * 0.55 }
        return Double(differenceCount) * 0.45
    }

    private static func keyDistance(_ lhs: ShortcutKey, _ rhs: ShortcutKey) -> Double {
        if lhs == rhs { return 0 }
        guard case let .character(left) = lhs, case let .character(right) = rhs else { return 3 }
        return areAdjacent(left, right) ? 0.75 : 3
    }

    private static func areAdjacent(_ lhs: String, _ rhs: String) -> Bool {
        let rows: [(String, Double)] = [
            ("1234567890", 0),
            ("QWERTYUIOP", 0.25),
            ("ASDFGHJKL", 0.55),
            ("ZXCVBNM", 0.9)
        ]
        func position(of key: String) -> (row: Int, column: Double)? {
            for (rowIndex, row) in rows.enumerated() {
                if let index = row.0.firstIndex(of: Character(key.uppercased())) {
                    return (rowIndex, Double(row.0.distance(from: row.0.startIndex, to: index)) + row.1)
                }
            }
            return nil
        }
        guard let left = position(of: lhs), let right = position(of: rhs) else { return false }
        return abs(left.row - right.row) <= 1 && abs(left.column - right.column) <= 1.15
    }

    private static func normalize(_ value: String) -> String {
        value.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
    }

    private static func searchableModifierNames(_ shortcut: ShortcutDefinition?) -> String {
        guard let shortcut else { return "" }
        let aliases: [ShortcutModifier: String] = [
            .control: "ctrl control контрол",
            .command: "cmd command команда",
            .option: "alt option опция",
            .shift: "shift шифт"
        ]
        return shortcut.modifiers.compactMap { aliases[$0] }.joined(separator: " ")
    }
}
