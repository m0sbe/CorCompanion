import AppKit
import SwiftUI

struct CompanionPopoverView: View {
    @ObservedObject var state: ApplicationState
    private let popoverWidth: CGFloat = 620
    private let popoverHeight: CGFloat = 578

    var body: some View {
        VStack(spacing: 0) {
            searchHeader
            Divider()
            ShortcutTableView(
                entries: state.filteredEntries,
                hasActiveFilter: !state.searchText.isEmpty || state.recordedShortcut != nil,
                showsApproximateMatches: state.isShowingApproximateMatches,
                exactMatchCount: state.recordedExactMatchCount,
                showsNearbyMatchesAfterExact: state.isShowingNearbyMatchesAfterExact,
                language: state.language
            )
            Divider()
            footer
            brandFooter
        }
        .frame(width: popoverWidth, height: popoverHeight)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var searchHeader: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField(AppStrings.searchPlaceholder(state.language), text: $state.searchText)
                    .textFieldStyle(.plain)
                    .onChange(of: state.searchText) { _ in state.recordedShortcut = nil }
                if !state.searchText.isEmpty || state.recordedShortcut != nil {
                    Button {
                        state.searchText = ""
                        state.recordedShortcut = nil
                    } label: { Image(systemName: "xmark.circle.fill") }
                    .buttonStyle(.plain).foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 10).frame(height: 32)
            .background(.quaternary.opacity(0.7), in: RoundedRectangle(cornerRadius: 7))

            HStack {
                Button {
                    state.isRecording = true
                    state.searchText = ""
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "keyboard")
                        Text(AppStrings.recordShortcut(state.language))
                    }
                    .font(.system(size: 16.8, weight: .medium))
                    .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
                recordArrow
                    .padding(.horizontal, 6)
                ShortcutRecorderView(shortcut: $state.recordedShortcut, isRecording: $state.isRecording, language: state.language)
                    .frame(width: 150, height: 28)
            }
        }
        .padding(12)
    }

    private var recordArrow: some View {
        Group {
            if let url = ResourceBundle.current.url(forResource: "RecordArrow", withExtension: "svg"),
               let image = NSImage(contentsOf: url) {
                Image(nsImage: image).resizable().scaledToFit()
            } else {
                HStack(spacing: 0) {
                    Rectangle().frame(height: 1)
                    Image(systemName: "arrowtriangle.right.fill")
                }
                .foregroundStyle(Color.corelAccent)
            }
        }
        .frame(width: 96, height: 26)
    }

    private var footer: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center) {
                Toggle(isOn: Binding(get: { state.panEnabled }, set: state.setPanEnabled)) {
                    HStack(spacing: 6) {
                        Text(AppStrings.panTitle(state.language))
                        Text(AppStrings.experimental(state.language)).font(.caption2).foregroundStyle(Color.corelAccent)
                    }
                }
                .toggleStyle(.switch)
                Spacer()
                Button { NSApp.terminate(nil) } label: {
                    Label(AppStrings.quit(state.language), systemImage: "power")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(Color.corelAccent)
                        .padding(.horizontal, 11)
                        .frame(height: 32)
                        .background(Color.corelAccent.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.corelAccent.opacity(0.28)))
                }
                .buttonStyle(.plain)
            }
            HStack {
                PanStatusText(controller: state.panController, language: state.language)
                if state.panController.needsPermissions {
                    Button(AppStrings.openPermissionSettings(state.language)) {
                        state.panController.requestPermissions()
                    }
                    .buttonStyle(.link)
                    .font(.caption)
                }
                Spacer()
                Text(AppStrings.language(state.language)).font(.caption).foregroundStyle(.secondary)
                Picker("", selection: Binding(get: { state.language }, set: state.setLanguage)) {
                    ForEach(AppLanguage.allCases) { language in Text(language.label).tag(language) }
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                .frame(width: 90)
            }
        }
        .padding(12)
    }

    private var brandFooter: some View {
        HStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.12), radius: 3, y: 1)

                if let url = ResourceBundle.current.url(forResource: "M0sbeeLogo", withExtension: "svg"),
                   let image = NSImage(contentsOf: url) {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .accessibilityLabel("M0sbee Design")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                }
            }
            .frame(width: 340, height: 48)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.leading, 8)
        .padding(.top, 2)
        .padding(.bottom, 8)
    }
}

private struct PanStatusText: View {
    @ObservedObject var controller: PanController
    let language: AppLanguage
    var body: some View {
        Text(AppStrings.panStatus(controller.status, language)).font(.caption).foregroundStyle(.secondary)
    }
}
