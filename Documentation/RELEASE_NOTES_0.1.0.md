# CorCompanion 0.1.0

Initial public preview for Apple Silicon Macs running macOS 13 or later.

## What is included

- English and Russian search across 96 CorelDRAW shortcut records
- Windows-to-macOS shortcut comparison
- Windows shortcut recorder with exact and nearby-match results
- Experimental middle mouse button panning for standard mice
- Automatic activation only while CorelDRAW is frontmost
- Local-only operation with no accounts, analytics or network requests

## Installation

Download `CorCompanion.dmg`, open it and drag CorCompanion to Applications.

This free build is not notarized by Apple. If macOS blocks the first launch, try opening the application once, then open **System Settings → Privacy & Security** and choose **Open Anyway** for CorCompanion.

Middle-button panning requires Accessibility and Input Monitoring permissions. Enable the installed `/Applications/CorCompanion.app` in both privacy lists when prompted.

## Current limitations

- Apple Silicon only
- macOS 13 or later
- Middle-button pan still requires final hands-on verification in CorelDRAW 2026
- Shortcut assignments can vary between CorelDRAW versions, workspaces and custom configurations

## Download verification

Download both `CorCompanion.dmg` and `CorCompanion.dmg.sha256`, place them in the same directory and run:

```sh
shasum -a 256 -c CorCompanion.dmg.sha256
```

The command should report `CorCompanion.dmg: OK`.
