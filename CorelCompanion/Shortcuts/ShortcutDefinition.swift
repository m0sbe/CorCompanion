import Foundation

enum ShortcutModifier: String, Codable, CaseIterable, Hashable {
    case control, command, option, shift
}

enum ShortcutKey: Hashable, Codable {
    case character(String)
    case arrowUp, arrowDown, arrowLeft, arrowRight
    case space, tab, enter, delete, escape
    case home, end, pageUp, pageDown
    case function(Int)

    private enum CodingKeys: String, CodingKey { case type, value }
    private enum Kind: String, Codable { case character, arrowUp, arrowDown, arrowLeft, arrowRight, space, tab, enter, delete, escape, home, end, pageUp, pageDown, function }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .type)
        switch kind {
        case .character: self = .character(try container.decode(String.self, forKey: .value).uppercased())
        case .function: self = .function(try container.decode(Int.self, forKey: .value))
        case .arrowUp: self = .arrowUp
        case .arrowDown: self = .arrowDown
        case .arrowLeft: self = .arrowLeft
        case .arrowRight: self = .arrowRight
        case .space: self = .space
        case .tab: self = .tab
        case .enter: self = .enter
        case .delete: self = .delete
        case .escape: self = .escape
        case .home: self = .home
        case .end: self = .end
        case .pageUp: self = .pageUp
        case .pageDown: self = .pageDown
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .character(value):
            try container.encode(Kind.character, forKey: .type)
            try container.encode(value.uppercased(), forKey: .value)
        case let .function(value):
            try container.encode(Kind.function, forKey: .type)
            try container.encode(value, forKey: .value)
        case .arrowUp: try container.encode(Kind.arrowUp, forKey: .type)
        case .arrowDown: try container.encode(Kind.arrowDown, forKey: .type)
        case .arrowLeft: try container.encode(Kind.arrowLeft, forKey: .type)
        case .arrowRight: try container.encode(Kind.arrowRight, forKey: .type)
        case .space: try container.encode(Kind.space, forKey: .type)
        case .tab: try container.encode(Kind.tab, forKey: .type)
        case .enter: try container.encode(Kind.enter, forKey: .type)
        case .delete: try container.encode(Kind.delete, forKey: .type)
        case .escape: try container.encode(Kind.escape, forKey: .type)
        case .home: try container.encode(Kind.home, forKey: .type)
        case .end: try container.encode(Kind.end, forKey: .type)
        case .pageUp: try container.encode(Kind.pageUp, forKey: .type)
        case .pageDown: try container.encode(Kind.pageDown, forKey: .type)
        }
    }
}

struct ShortcutDefinition: Codable, Hashable {
    let modifiers: Set<ShortcutModifier>
    let key: ShortcutKey
}
