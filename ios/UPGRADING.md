# iOS — Upgrade notes

The app was migrated from **Swift 2 (Xcode 7.1, 2016)** to **Swift 5**,
building with **Xcode 26 / Swift 6.2 toolchain** for the iOS Simulator.

> **Status: build-verified.** `xcodebuild` for the iOS Simulator
> succeeds with 0 errors, and the app installs and launches in the
> simulator without crashing. The full search flow needs a running
> backend and was not exercised end-to-end here — see "Not verified".

## What changed

### Project / build config
| Item | Before | After |
|------|--------|-------|
| Swift | 2.x (no `SWIFT_VERSION`) | `SWIFT_VERSION = 5.0` |
| Deployment target | iOS 8.1 / 9.1 | iOS 16.0 |
| Dependency manager | CocoaPods | none (removed) |
| `Alamofire ~> 3` | networking | removed → `URLSession` |
| `GoogleMaps` pod | maps/places | removed |

All CocoaPods integration was stripped from `project.pbxproj`
(framework link, `Check Pods Manifest.lock` / `Embed Pods` /
`Copy Pods Resources` script phases, `baseConfigurationReference`
xcconfig refs, Pods groups). `Podfile` deleted. The project now builds
as a plain `.xcodeproj` with **no third-party dependencies**.

### Source migration (Swift 2 → 5)
- Foundation/UIKit renames: `NSURL`/`NSURLSession`/`NSURLRequest`/
  `NSHTTPURLResponse`/`NSJSONSerialization`/`NSData`/`NSFileManager`/
  `NSNotificationCenter`/`NSIndexPath` → modern types; `dispatch_async`
  → `DispatchQueue.main.async`; `.enabled`→`.isEnabled`;
  `isFirstResponder()`→`isFirstResponder`; enum cases lowercased.
- Selector strings (`"handleSingleTap:"`) → `#selector(...)` with
  `@objc` methods.
- All `UITableView*`/lifecycle delegate signatures updated to the
  Swift 3+ "grand renaming" form (`numberOfSections(in:)`,
  `cellForRowAt:`, `prepare(for:sender:)`, `viewWillAppear(_:)` …).
- `NSCoding`: `encodeWithCoder`/`decodeObjectForKey` →
  `encode(with:)`/`decodeObject(forKey:)`, failable decoder hardened
  with `guard`.
- Networking rewritten on `URLSession` (replaces Alamofire) for both
  the Google geocoding call and the restaurant API call; JSON via
  `JSONSerialization`.
- IBAction signatures kept as `func name(_ sender:)` so the Obj-C
  selectors still match the storyboard connections
  (`searchRestaurant:`, `getCurrentLocation:`, `pickPlace:`).

### Deliberate scope decision: Google Places removed
`getCurrentLocation` and `pickPlace` depended on `GMSPlacesClient`'s
old `currentPlace` callback and `GMSPlacePicker`. Google **removed
`GMSPlacePicker`** and redesigned the Places API into a separate, paid
SDK. Reimplementing against it is out of scope and unverifiable without
a billing-enabled API key. Those two buttons now show an alert telling
the user to type the location manually. The core flow (type location +
type → geocode → fetch restaurants → show random + list) is unaffected
and needs no Maps SDK. Storyboard connections were preserved (the
IBActions still exist), so no storyboard edits were needed.

## How to verify

```bash
cd ios
xcodebuild -project Search_Restaurant.xcodeproj -scheme Search_Restaurant \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  -configuration Debug CODE_SIGNING_ALLOWED=NO build
```

Expected: `** BUILD SUCCEEDED **`, exit 0. Two warnings remain by
design — the legacy `NSKeyedArchiver.archiveRootObject` /
`unarchiveObject(withFile:)` calls are kept (and commented) to preserve
the on-disk archive format shared between the two view controllers.

## Not verified / follow-ups

- End-to-end search was not run (needs the Django backend reachable and
  a valid Google geocoding API key in `ViewController.swift`).
- `Restaurant` photo download uses synchronous `Data(contentsOf:)`
  inside the URLSession callback (preserves original behavior); could
  move to async image loading.
- Swift 5 language mode (not Swift 6 strict concurrency) — intentional,
  lower-risk for a sample app. Moving to Swift 6 mode would surface
  main-actor isolation work.
- Legacy keyed-archiver persistence could move to
  `Codable` + `unarchivedObject(ofClass:from:)`.
- Test targets are still empty stubs.
