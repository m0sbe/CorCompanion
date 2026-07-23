# Architecture and feasibility

CorCompanion targets macOS 13 or newer on Apple Silicon (`arm64`) only. Ventura keeps the useful audience broad while providing the SwiftUI and AppKit APIs used by the popover. Newer macOS releases are supported by using public APIs and availability checks for any future version-specific additions; never branch on a fixed list of OS version numbers. The app is an `LSUIElement`, so it has no Dock icon. Its status item remains visible so the user can always open or quit the utility; `NSWorkspace` notifications still ensure pan operates only while CorelDRAW is active. There is no polling.

## Modules

- `App` composes dependencies and owns lifecycle.
- `StatusBar` owns `NSStatusItem` and the transient `NSPopover`.
- `Shortcuts` decodes a bundle JSON catalogue and performs local normalized search.
- `ShortcutRecorder` is a first-responder `NSView`; it does not install a global keyboard listener.
- `CorelMonitoring` separates running and active CorelDRAW state. The verified 2026 bundle identifier is `com.corel.coreldrawsuite.2026.coreldraw`.
- `Pan` is optional and isolated from the UI. Its event tap exists only while the feature is enabled, Accessibility is trusted, and CorelDRAW is frontmost.

## Pan risk assessment

No documented CorelDRAW viewport automation API was found in the installed CorelDRAW 2026 bundle. Corel's official Mac shortcut card documents `H` for Pan. The prototype selects Pan, converts button 2 into a primary-button drag, then sends Space after mouse-up. In CorelDRAW 2026 this toggles Pan back to the previously active toolbox state; this behavior is validated empirically because it is not described in the public shortcut card. It must be tested with an actual document and mouse and is not declared production-ready. There is no process injection, private API, root component, driver, or CorelDRAW file modification.

Further risks are Accessibility and Input Monitoring consent, coordinate behavior across displays, full-screen spaces, and device-specific button numbering. While pan is eligible to run, a low-frequency health monitor checks the event tap every five seconds and recreates it if macOS disabled or invalidated it after timeout, sleep, or prolonged inactivity. Ad-hoc builds receive a cdhash-based trust requirement, so an updated binary can require fresh TCC consent. Developer ID is the only recommended route to a stable release identity plus Gatekeeper trust and notarization; CorCompanion intentionally avoids custom Keychain identities. Failure leaves the shortcut reference functional.
