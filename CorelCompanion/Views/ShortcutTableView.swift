import SwiftUI

struct ShortcutTableView: View {
    let entries: [ShortcutEntry]
    let hasActiveFilter: Bool
    let showsApproximateMatches: Bool
    let exactMatchCount: Int
    let showsNearbyMatchesAfterExact: Bool
    let language: AppLanguage

    var body: some View {
        VStack(spacing: 0) {
            tableHeader
            if showsApproximateMatches {
                HStack(spacing: 6) {
                    Image(systemName: "scope")
                    Text(AppStrings.approximateMatches(language))
                    Spacer()
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .frame(height: 28)
                .background(Color.corelAccent.opacity(0.055))
            }
            Divider()
            if entries.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "keyboard.badge.ellipsis").font(.system(size: 28)).foregroundStyle(.secondary)
                    Text(hasActiveFilter ? AppStrings.noMatch(language) : AppStrings.emptyReference(language))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                            if showsNearbyMatchesAfterExact, index == exactMatchCount {
                                nearbyHeader
                            }
                            ShortcutRow(entry: entry, language: language)
                            Divider().padding(.leading, 12)
                        }
                    }
                }
            }
        }
    }

    private var nearbyHeader: some View {
        HStack(spacing: 7) {
            Text(AppStrings.nearbyMatches(language))
                .font(.caption2.weight(.semibold))
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
            Rectangle()
                .fill(Color.secondary.opacity(0.18))
                .frame(height: 1)
        }
        .padding(.horizontal, 12)
        .frame(height: 27)
        .background(Color.corelAccent.opacity(0.035))
    }

    private var tableHeader: some View {
        HStack(spacing: 12) {
            Text(AppStrings.commandName(language)).frame(maxWidth: .infinity, alignment: .leading)
            Text("Windows").frame(width: 135, alignment: .leading)
            Text("macOS").frame(width: 105, alignment: .leading)
        }
        .font(.caption.weight(.semibold)).foregroundStyle(.secondary)
        .padding(.horizontal, 12).frame(height: 30)
        .background(.bar)
    }
}

private struct ShortcutRow: View {
    let entry: ShortcutEntry
    let language: AppLanguage
    @State private var hovering = false

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(language == .ru ? entry.titleRU : (entry.titleEN ?? entry.titleRU)).lineLimit(2)
                if let alternateTitle {
                    Text(alternateTitle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            ShortcutBadge(text: ShortcutFormatter.windows(entry.windowsShortcut)).frame(width: 135, alignment: .leading)
            ShortcutBadge(text: ShortcutFormatter.macOS(entry.macShortcut)).frame(width: 105, alignment: .leading)
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(hovering ? Color.accentColor.opacity(0.09) : .clear)
        .contentShape(Rectangle())
        .onHover { hovering = $0 }
    }

    private var alternateTitle: String? {
        if language == .ru { return entry.titleEN }
        return entry.titleEN == nil ? nil : entry.titleRU
    }
}

private struct ShortcutBadge: View {
    let text: String
    var body: some View {
        Text(text).font(.system(.caption, design: .monospaced).weight(.medium))
            .padding(.horizontal, 7).padding(.vertical, 4)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 5))
    }
}
