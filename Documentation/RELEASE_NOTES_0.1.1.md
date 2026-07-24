# CorCompanion 0.1.1

Bug-fix release for Apple Silicon Macs running macOS 13 or later.

## Fixed

- Fixed middle-button panning being blocked by an unnecessary Input Monitoring permission check.
- CorCompanion now requires only Accessibility permission for middle-button panning.
- Release builds no longer leave a second runnable copy in the build output, preventing duplicate CorCompanion entries in macOS Accessibility settings.

## Installation

Download `CorCompanion.dmg`, open it and drag CorCompanion to Applications. Replace the previous version if macOS asks.

This free build is not notarized by Apple. If macOS blocks the first launch, try opening the application once, then open **System Settings → Privacy & Security** and choose **Open Anyway** for CorCompanion.

Enable the installed `/Applications/CorCompanion.app` in **System Settings → Privacy & Security → Accessibility** when prompted.

## Requirements and limitations

- Apple Silicon only
- macOS 13 or later
- CorelDRAW for Mac; CorelDRAW 2026 is the currently targeted version
- Shortcut assignments can vary between CorelDRAW versions, workspaces and custom configurations

## Download verification

Download both `CorCompanion.dmg` and `CorCompanion.dmg.sha256`, place them in the same directory and run:

```sh
shasum -a 256 -c CorCompanion.dmg.sha256
```

The command should report `CorCompanion.dmg: OK`.
