# Free GitHub release (ad-hoc signed)

1. Update `APP_VERSION` and `BUILD_NUMBER` in `Config/BuildSettings.env`.
2. Run `scripts/build-github-release.sh`.
3. Upload both `dist/CorCompanion.dmg` and `dist/CorCompanion.dmg.sha256` to the matching GitHub Release.
4. Publish the tag from the exact source revision used for the build.
5. Test the download and first-launch flow on a clean macOS account.

The app is ad-hoc signed. This protects its internal code-signing structure but does not identify the developer to Gatekeeper and cannot be notarized. An update can require Accessibility and Input Monitoring again because its code hash changes. Users may need to approve the app in System Settings → Privacy & Security. Never instruct users to disable Gatekeeper globally.

# Optional Developer ID release

1. Install the current stable Xcode and select it with `sudo xcode-select -s /Applications/Xcode.app`.
2. Open `Package.swift` in Xcode, choose the CorelCompanion executable scheme, and verify tests with `swift test` or Product → Test.
3. Run `scripts/build-app.sh` for a locally signed `.app`, or archive the executable in Xcode with Release optimization.
4. Sign the bundle using a Developer ID Application certificate and Hardened Runtime:
   `codesign --force --deep --options runtime --entitlements Config/CorelCompanion.entitlements --sign "Developer ID Application: …" "dist/CorCompanion.app"`
5. Create the DMG with `scripts/create-dmg.sh`.
6. Submit with `xcrun notarytool submit "dist/CorCompanion.dmg" --keychain-profile PROFILE --wait` and staple with `xcrun stapler staple "dist/CorCompanion.dmg"`.
7. Verify using `codesign --verify --deep --strict`, `spctl --assess --type execute`, and `spctl --assess --type open --context context:primary-signature` on the DMG. Repeat the install and permission flow on a clean macOS account.

Developer ID credentials and notarization cannot be embedded in the repository. Releases intentionally contain only an `arm64` slice. Update `Config/BuildSettings.env` for a new release; `scripts/build-app.sh` pins the deployment target and runs `scripts/verify-compatibility.sh` to reject an incorrect architecture or minimum macOS version.
