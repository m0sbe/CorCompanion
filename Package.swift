// swift-tools-version: 6.0
import Foundation
import PackageDescription

let settingsURL = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .appendingPathComponent("Config/BuildSettings.env")
let buildSettings = (try? String(contentsOf: settingsURL, encoding: .utf8))?
    .split(whereSeparator: \Character.isNewline)
    .reduce(into: [String: String]()) { result, line in
        let parts = line.split(separator: "=", maxSplits: 1).map(String.init)
        if parts.count == 2, !parts[0].hasPrefix("#") { result[parts[0]] = parts[1] }
    } ?? [:]
let minimumMacOSVersion = buildSettings["MIN_MACOS_VERSION"] ?? "13.0"

let package = Package(
    name: "CorelCompanion",
    platforms: [.macOS(.init(stringLiteral: minimumMacOSVersion))],
    products: [.executable(name: "CorelCompanion", targets: ["CorelCompanion"])],
    targets: [
        .executableTarget(
            name: "CorelCompanion",
            path: "CorelCompanion",
            resources: [.process("Resources")],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "CorelCompanionTests",
            dependencies: ["CorelCompanion"],
            path: "Tests/CorelCompanionTests",
            resources: [.copy("Fixtures")],
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)
