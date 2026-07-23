import XCTest
@testable import CorelCompanion

final class ShortcutTests: XCTestCase {
    private let controlQ = ShortcutDefinition(modifiers: [.control], key: .character("Q"))
    private let commandG = ShortcutDefinition(modifiers: [.command], key: .character("G"))

    func testWindowsFormatting() {
        XCTAssertEqual(ShortcutFormatter.windows(controlQ), "Ctrl + Q")
    }

    func testMacFormatting() {
        XCTAssertEqual(ShortcutFormatter.macOS(commandG), "⌘G")
    }

    func testJSONNormalizesCharacterCase() throws {
        let data = #"{"modifiers":["control"],"key":{"type":"character","value":"q"}}"#.data(using: .utf8)!
        XCTAssertEqual(try JSONDecoder().decode(ShortcutDefinition.self, from: data), controlQ)
    }

    func testRussianEnglishAndPartialSearch() {
        let entries = sampleEntries()
        XCTAssertEqual(ShortcutSearchEngine.search("крив", in: entries).map(\.titleRU), ["Преобразовать в кривые"])
        XCTAssertEqual(ShortcutSearchEngine.search("GROUP", in: entries).map(\.titleRU), ["Группировать"])
        XCTAssertEqual(ShortcutSearchEngine.search("преобразовать кривые", in: entries).count, 1)
    }

    @MainActor
    func testBundledCatalogueIsValidAndSearchable() {
        let entries = ShortcutRepository().entries
        XCTAssertGreaterThanOrEqual(entries.count, 90)
        XCTAssertEqual(Set(entries.map(\.id)).count, entries.count)
        XCTAssertTrue(entries.allSatisfy { $0.windowsShortcut != nil || $0.macShortcut != nil })
        XCTAssertFalse(ShortcutSearchEngine.search("абрис", in: entries).isEmpty)
        XCTAssertFalse(ShortcutSearchEngine.search("group", in: entries).isEmpty)
        XCTAssertFalse(ShortcutSearchEngine.search("command g", in: entries).isEmpty)
        XCTAssertFalse(ShortcutSearchEngine.search("ctrl q", in: entries).isEmpty)
    }

    func testShortcutLookupAndNoResult() {
        let entries = sampleEntries()
        XCTAssertEqual(ShortcutSearchEngine.matchingWindowsShortcut(controlQ, in: entries).count, 1)
        XCTAssertTrue(ShortcutSearchEngine.matchingWindowsShortcut(commandG, in: entries).isEmpty)
    }

    func testRecordedMacShortcutIsAnExactMatch() {
        let entries = sampleEntries()
        let matches = ShortcutSearchEngine.matchingRecordedShortcut(commandG, in: entries)

        XCTAssertEqual(matches.map(\.titleRU), ["Группировать"])
        XCTAssertEqual(ShortcutSearchEngine.rankedRecordedMatches(commandG, in: entries).first?.distance, 0)
    }

    func testExactRecordedMatchAlsoIncludesNearbyMatchesAfterIt() {
        let nearby = ShortcutEntry(
            id: UUID(), category: .object, titleRU: "Близкая команда", titleEN: "Nearby Command",
            windowsShortcut: .init(modifiers: [.control, .shift], key: .character("G")),
            macShortcut: .init(modifiers: [.command, .shift], key: .character("G")), notes: nil
        )
        let matches = ShortcutSearchEngine.rankedRecordedMatches(commandG, in: sampleEntries() + [nearby])

        XCTAssertEqual(matches.first?.entry.titleRU, "Группировать")
        XCTAssertEqual(matches.first?.distance, 0)
        XCTAssertEqual(matches.dropFirst().first?.entry.titleRU, "Близкая команда")
        XCTAssertTrue(matches.dropFirst().allSatisfy { $0.distance > 0 })
    }

    func testRecorderUsesPhysicalANSIKeyRegardlessOfInputLanguage() {
        XCTAssertEqual(KeyEventNormalizer.key(forKeyCode: 35), .character("P"))
        XCTAssertEqual(KeyEventNormalizer.key(forKeyCode: 6), .character("Z"))
        XCTAssertEqual(KeyEventNormalizer.key(forKeyCode: 20), .character("3"))
    }

    func testApproximateShortcutMatchingIsRankedAndBounded() {
        let entries = sampleEntries()
        let optionQ = ShortcutDefinition(modifiers: [.option], key: .character("Q"))
        let commandShiftQ = ShortcutDefinition(modifiers: [.command, .shift], key: .character("Q"))
        let unrelated = ShortcutDefinition(modifiers: [.option], key: .character("M"))

        XCTAssertEqual(ShortcutSearchEngine.rankedWindowsMatches(optionQ, in: entries).first?.entry.titleRU, "Преобразовать в кривые")
        XCTAssertEqual(ShortcutSearchEngine.rankedWindowsMatches(commandShiftQ, in: entries).first?.entry.titleRU, "Преобразовать в кривые")
        XCTAssertTrue(ShortcutSearchEngine.rankedWindowsMatches(unrelated, in: entries).isEmpty)
    }

    private func sampleEntries() -> [ShortcutEntry] {
        [
            ShortcutEntry(id: UUID(), category: .object, titleRU: "Преобразовать в кривые", titleEN: "Convert to Curves", windowsShortcut: controlQ, macShortcut: controlQ, notes: nil),
            ShortcutEntry(id: UUID(), category: .object, titleRU: "Группировать", titleEN: "Group", windowsShortcut: .init(modifiers: [.control], key: .character("G")), macShortcut: commandG, notes: nil)
        ]
    }
}
