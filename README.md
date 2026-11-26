# LocSim (trimmed from Andromeda 2.5.2)

A buildable fork of [Andromeda](https://github.com/son3ra1n/Andromeda) that keeps **exactly one feature: LocSim Pro — location simulation**: map tap, address search, joystick, route / GPX simulation, app profiles, favorites, altitude and the auto-stop timer.

Everything else was removed: Home, Daemons Manager, Cleaner / Storage Analyzer, Superviser (skip-setup), ByeTime / Screen Time, and the shared bookmark Share-Extension appex.

## How it works
- `LocSimManager` drives `CLSimulationManager` from the private `CoreLocation` `CLSimulation` framework.
- The app is **TrollStore-only**: it needs the `com.apple.locationd.simulation` entitlement, inlined by `ldid` from `entitlements.plist` (no developer certificate, no provisioning profile).
- iOS 15.0 – 17.0 (the TrollStore-supported versions).

## Trim map
| Removed | Why |
|---|---|
| onboarding sheet + `AppSettings` in `GeraniumApp.swift` | replaced by a single-entry view plus a sandbox probe |
| `HomeView.swift` | landing page for all tools |
| `SettingsView.swift` | Cleaner / Daemons / ByeTime / Supervise settings |
| `WelcomeView.swift`, `BetaChecker.swift` | first-run onboarding, beta gate |
| `Cleaner/`, `DaemonMan/`, `ByeTime/`, `The Supviser/` | the other four feature groups |
| `Icons/`, `Translations/` | alt-icon picker, localisation strings |
| `Bookmark Location in Geranium/` appex | shared bookmark extension (the main app keeps its own bookmark store) |
| `Geranium.xcodeproj` | replaced by `LocSimOnly.xcodeproj` |
| `RootHelper/` (theos sources) | prebuilt `GeraniumRootHelper` binary already ships in the bundle |
| `Assets/`, `Media/`, `icon.sketch` | README screenshots / design assets |

## Building

### Option A: Xcode GUI
1. `open LocSimOnly.xcodeproj`
2. Xcode > File > Add Package Dependencies > `https://github.com/sparrowcode/AlertKit`
   (adds the `AlertKit` product the code imports; iOS 15 deployment target is enough).
3. Select the `Geranium` scheme, destination *Any iOS Device (arm64)*.
4. Product > Archive > Distribute App > Copy App, then:
   ```bash
   mkdir -p Payload && cp -R LocSim.app Payload/
   ldid -S entitlements.plist LocSim.app/LocSim
   zip -qr LocSim.tipa Payload/
   ```

### Option B: script (macOS + Xcode 15 + `brew install ldid`)
```bash
./build-tipa.sh          # produces build/LocSim.tipa
```

Either way the output is a TrollStore-installable `.tipa`. `build-tipa.sh` does a
Release build with `CODE_SIGNING_ALLOWED=NO`, strips `_CodeSignature` /
`embedded.mobileprovision`, and applies `ldid -S entitlements.plist` to the main
binary and to `GeraniumRootHelper`, which is what injects
`com.apple.locationd.simulation`.

## App dependencies / wiring
- SwiftPM package `AlertKit` (`https://github.com/sparrowcode/AlertKit`) — referenced by
  `LocSimOnly.xcodeproj` and by every LocSim view.
- `Geranium/Libs/TrollStore/TSUtil.m` is compiled into the app target and exposes
  `spawnRoot`, `killall`, `loadMCMFramework`; declared in `TSUtil.h` and imported through
  the bridging header `Geranium/Geranium-Bringing-Header.h`.
- `Geranium/LocSim/LocSimPrivateHeaders.h` declares the private `CLSimulationManager`
  (`appendSimulatedLocation:`, `startLocationSimulation`, `stopLocationSimulation`, `flush`).
- The bundled unsandboxed helper `Geranium/GeraniumRootHelper` is copied by the
  *Copy RootHelper* build phase and signed with the same entitlements.

## Verified
- Source: `Andromeda v2.5.2` (GPL-3.0) — son3ra1n, `ghproxy.net` mirror commit `bc1e1d3c0646cf03d99d3975c000c49d478bf2a8`.
- Original `.tipa` unpacked to `Payload/Geranium.app` (main binary `Geranium`, 76 768 B; `Geranium.debug.dylib` 7 882 200 B; `GeraniumRootHelper` arm64 Mach-O, 103 184 B).
- `GeraniumRootHelper` was inspected with a Mach-O parser: thin arm64 (`0x0100000c`), `MH_EXECUTE`, references `SpringBoardServices` / `BackBoardServices` (matches `killall`), no Swift/Foundation framework surface — it is a kill-helper, not a locationd bridge. Location simulation therefore runs **in-process** via `CLSimulationManager`, and the root helper is not required for it.
- `project.pbxproj` of `LocSimOnly.xcodeproj`: full OpenStep parser round-trip, **0 missing refs, 0 unused objects**, every one of the 18 sources resolves to a file on disk.
- Remaining 18 sources (the whole LocSim feature): `GeraniumApp.swift`, `ContentView.swift`, `LocSim/{AppProfilesView, CustomMapView, CoordTransform, FavoritesView, FloatingQuickMenu, GPXParser, JoystickView, LocSimManager, LocSimView, RouteSimulator, RouteSimView}`, `LocSim/BookMark/{BookMarkHelper, BookMarkSlider}`, `Libs/{Addon, RootHelperMan}`, `Libs/TrollStore/TSUtil.m`.
- `xcodebuild` compile: **NOT RUN in this session** — no macOS/Xcode here.

## Notes
- On iOS 16+ the original repo used `UIApplication.shared.TextFieldAlert`. This trimmed tree ships
  `LowBar.swift`, a UIKit-free alert helper using `UIAlertController` + a text field, so the two
  call sites in `LocSimView.swift` and `BookMarkSlider.swift` compile without touching `UIApplication`.
