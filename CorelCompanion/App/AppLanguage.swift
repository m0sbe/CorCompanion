import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case ru
    case en

    var id: String { rawValue }
    var label: String { rawValue.uppercased() }

    static func resolved(from preferredLanguages: [String] = Locale.preferredLanguages) -> AppLanguage {
        preferredLanguages.first?.lowercased().hasPrefix("ru") == true ? .ru : .en
    }
}

enum AppStrings {
    static func searchPlaceholder(_ language: AppLanguage) -> String {
        language == .ru ? "Поиск команды или сочетания Windows" : "Search commands or Windows shortcuts"
    }

    static func recordShortcut(_ language: AppLanguage) -> String {
        language == .ru ? "Введите сочетание Windows" : "Enter a Windows shortcut"
    }

    static func pressShortcut(_ language: AppLanguage) -> String {
        language == .ru ? "Нажмите сочетание…" : "Press a shortcut…"
    }

    static func commandName(_ language: AppLanguage) -> String {
        language == .ru ? "Название команды" : "Command name"
    }

    static func approximateMatches(_ language: AppLanguage) -> String {
        language == .ru
            ? "Точных совпадений нет — показаны ближайшие сочетания"
            : "No exact match — showing the closest shortcuts"
    }

    static func nearbyMatches(_ language: AppLanguage) -> String {
        language == .ru ? "Близкие" : "Close matches"
    }

    static func noMatch(_ language: AppLanguage) -> String {
        language == .ru ? "Сочетание не найдено в справочнике" : "Shortcut not found in the reference"
    }

    static func emptyReference(_ language: AppLanguage) -> String {
        language == .ru ? "Справочник пуст" : "The shortcut reference is empty"
    }

    static func panTitle(_ language: AppLanguage) -> String {
        language == .ru ? "Перемещение холста средней кнопкой" : "Pan canvas with the middle button"
    }

    static func experimental(_ language: AppLanguage) -> String {
        language == .ru ? "Экспериментально" : "Experimental"
    }

    static func openPermissionSettings(_ language: AppLanguage) -> String {
        language == .ru ? "Выдать доступ" : "Grant access"
    }

    static func quit(_ language: AppLanguage) -> String {
        language == .ru ? "Завершить CorCompanion" : "Quit CorCompanion"
    }

    static func language(_ language: AppLanguage) -> String {
        language == .ru ? "Язык" : "Language"
    }

    static func firstLaunchTitle(_ language: AppLanguage) -> String {
        language == .ru ? "CorCompanion запущен" : "CorCompanion is running"
    }

    static func firstLaunchMessage(_ language: AppLanguage) -> String {
        language == .ru
            ? "CorCompanion появится в строке меню, когда активен CorelDRAW."
            : "CorCompanion appears in the menu bar while CorelDRAW is active."
    }

    static func understood(_ language: AppLanguage) -> String {
        language == .ru ? "Понятно" : "Got it"
    }

    static func panStatus(_ status: PanStatus, _ language: AppLanguage) -> String {
        switch (status, language) {
        case (.inactive, .ru): "Работает только при активном CorelDRAW."
        case (.inactive, .en): "Works only while CorelDRAW is active."
        case (.missingBothPermissions, .ru): "Требуются «Универсальный доступ» и «Мониторинг ввода»."
        case (.missingBothPermissions, .en): "Accessibility and Input Monitoring permissions are required."
        case (.missingAccessibility, .ru): "Требуется разрешение «Универсальный доступ»."
        case (.missingAccessibility, .en): "Accessibility permission is required."
        case (.missingInputMonitoring, .ru): "Требуется разрешение «Мониторинг ввода»."
        case (.missingInputMonitoring, .en): "Input Monitoring permission is required."
        case (.waitingForCorel, .ru): "Ожидание активного CorelDRAW."
        case (.waitingForCorel, .en): "Waiting for CorelDRAW to become active."
        case (.active, .ru): "Прототип активен. Удерживайте среднюю кнопку над холстом."
        case (.active, .en): "Prototype active. Hold the middle button over the canvas."
        case (.eventTapFailed, .ru): "Не удалось запустить перехват мыши. Проверьте разрешения."
        case (.eventTapFailed, .en): "Could not start mouse capture. Check permissions."
        }
    }
}

extension Color {
    static let corelAccent = Color(red: 209 / 255, green: 24 / 255, blue: 24 / 255)
}

extension NSColor {
    static let corelAccent = NSColor(srgbRed: 209 / 255, green: 24 / 255, blue: 24 / 255, alpha: 1)
}
