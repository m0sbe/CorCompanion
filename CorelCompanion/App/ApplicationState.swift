import AppKit
import Combine

@MainActor
final class ApplicationState: ObservableObject {
    @Published var searchText = ""
    @Published var recordedShortcut: ShortcutDefinition?
    @Published var isRecording = false
    @Published var language: AppLanguage
    @Published var panEnabled: Bool {
        didSet { panController.setUserEnabled(panEnabled) }
    }

    let repository: ShortcutRepository
    let applicationMonitor: ActiveApplicationMonitor
    let panController: PanController
    private var cancellables = Set<AnyCancellable>()

    init(repository: ShortcutRepository, applicationMonitor: ActiveApplicationMonitor, panController: PanController) {
        self.repository = repository
        self.applicationMonitor = applicationMonitor
        self.panController = panController
        if let saved = UserDefaults.standard.string(forKey: "appLanguage"), let savedLanguage = AppLanguage(rawValue: saved) {
            language = savedLanguage
        } else {
            language = AppLanguage.resolved()
        }
        panEnabled = UserDefaults.standard.bool(forKey: "middleButtonPanEnabled")

        applicationMonitor.$isCorelActive
            .removeDuplicates()
            .sink { [weak panController] isActive in panController?.setCorelActive(isActive) }
            .store(in: &cancellables)
        panController.setUserEnabled(panEnabled)
    }

    var filteredEntries: [ShortcutEntry] {
        if let recordedShortcut {
            return ShortcutSearchEngine.rankedRecordedMatches(recordedShortcut, in: repository.entries).map(\.entry)
        }
        return ShortcutSearchEngine.search(searchText, in: repository.entries)
    }

    var isShowingApproximateMatches: Bool {
        guard let recordedShortcut else { return false }
        return ShortcutSearchEngine.matchingRecordedShortcut(recordedShortcut, in: repository.entries).isEmpty
            && !ShortcutSearchEngine.rankedRecordedMatches(recordedShortcut, in: repository.entries).isEmpty
    }

    var recordedExactMatchCount: Int {
        guard let recordedShortcut else { return 0 }
        return ShortcutSearchEngine.rankedRecordedMatches(recordedShortcut, in: repository.entries)
            .prefix { $0.distance == 0 }
            .count
    }

    var isShowingNearbyMatchesAfterExact: Bool {
        guard let recordedShortcut else { return false }
        let matches = ShortcutSearchEngine.rankedRecordedMatches(recordedShortcut, in: repository.entries)
        return matches.contains { $0.distance == 0 } && matches.contains { $0.distance > 0 }
    }

    func setPanEnabled(_ enabled: Bool) {
        panEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "middleButtonPanEnabled")
    }

    func setLanguage(_ language: AppLanguage) {
        self.language = language
        UserDefaults.standard.set(language.rawValue, forKey: "appLanguage")
    }

    func shutdown() {
        applicationMonitor.stop()
        panController.shutdown()
    }

    func refreshPermissions() {
        panController.refreshPermissions()
    }
}
