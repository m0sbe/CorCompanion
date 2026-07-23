import Foundation

@MainActor
final class ShortcutRepository {
    private(set) var entries: [ShortcutEntry] = []
    private(set) var loadError: String?

    init(bundle: Bundle = ResourceBundle.current) {
        guard let url = bundle.url(forResource: "shortcuts", withExtension: "json") else {
            loadError = "Файл справочника не найден."
            return
        }
        do {
            entries = try JSONDecoder().decode([ShortcutEntry].self, from: Data(contentsOf: url))
        } catch {
            loadError = "Не удалось загрузить справочник: \(error.localizedDescription)"
        }
    }
}
