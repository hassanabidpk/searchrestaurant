# iOS — Upgrade plan (NOT YET DONE)

> **Status: not started — documentation only.** This app is **Swift 2**
> (Xcode 7.1, 2015). Upgrading it spans four simultaneous major
> migrations and is a **compiler-driven, interactive job that must be
> done in Xcode on macOS**. It was deliberately not attempted blind —
> a hand-edited Swift 2→6 rewrite without a compiler would be guesswork.
> This file is the concrete plan to follow when someone has Xcode.

## Current state

| Item | Value |
|------|-------|
| Language | Swift 2.x (pre-Swift-3 "Grand Renaming") |
| Xcode project | `objectVersion = 46`, `LastUpgradeCheck = 0710` |
| Deployment target | iOS 8.1 / 9.1 |
| Dependency mgmt | CocoaPods |
| Pods | `Alamofire ~> 3.0`, `GoogleMaps` (unversioned) |
| Code | ~763 LOC; `ViewController.swift` is 490 |

Swift 2 markers present throughout: `numberOfSectionsInTableView(tableView:)`,
`cellForRowAtIndexPath:`, `viewWillAppear(animated:)`, `NSURLSession.sharedSession()`,
`NSIndexPath`, `prepareForSegue(_:sender:)`.

## Recommended target

- Swift 5 (or 6), latest stable Xcode
- iOS deployment target 15+ (12 minimum)
- `Alamofire 5.x` or drop it for `URLSession` (only one network call —
  `ViewController.swift:213` already uses `NSURLSession`; removing the
  Alamofire dependency is the lower-risk option)
- Google Maps iOS SDK 8.x/9.x (Swift Package Manager preferred over CocoaPods)

## Step order (do in Xcode, one stage at a time, compile between each)

1. **Backup / branch.** This is destructive churn; isolate it.
2. **Open in current Xcode**, let it run *Edit ▸ Convert ▸ To Current
   Swift Syntax* (Swift 2→3). Build. Fix what the converter cannot.
3. **Swift 3→4→5** incrementally via the project's Swift Language Version
   build setting; build and fix at each bump. Expect heavy churn in
   `ViewController.swift` and `RestaurantTableViewController.swift`
   (every UIKit delegate signature changed in Swift 3).
4. **Foundation renames:** `NSURLSession`→`URLSession`,
   `NSIndexPath`→`IndexPath`, `NSData`→`Data`, etc.
5. **Dependencies:**
   - Migrate CocoaPods → Swift Package Manager (or update the `Podfile`:
     `platform :ios, '15.0'`, modern pod versions, remove the empty
     test targets, drop the per-target `source`).
   - `Alamofire 3` API is incompatible with 5 — rewrite the call, or
     replace with `URLSession` (recommended; minimal usage).
   - Update Google Maps SDK + its init in `AppDelegate.swift` /
     `ViewController.swift`; new SDK needs an API key via
     `GMSServices.provideAPIKey(_:)` (already the pattern, verify args).
6. **Project format:** let Xcode update `objectVersion` / recommended
   settings; set a real deployment target; remove `LastUpgradeCheck`
   staleness.
7. **Build for simulator, run, exercise:** map screen, restaurant
   search/list, detail. There are no real tests — the test targets are
   empty stubs.

## Verification (requires macOS + Xcode)

```bash
cd ios
pod install            # if staying on CocoaPods
xcodebuild -workspace Search_Restaurant.xcworkspace \
  -scheme Search_Restaurant -sdk iphonesimulator build
```

Then run in the simulator and click through every screen — the only
meaningful verification, since the app has no automated test coverage.

## Why this wasn't auto-applied

Unlike the Django backend (verifiable headless via `manage.py check`)
and the Android module (a mechanical AndroidX import migration), a
Swift 2→5/6 upgrade is interactive: the Xcode migrator + compiler drive
it, and each stage's fixes depend on the previous stage's compiler
errors. Doing it without a build loop would produce unverifiable,
likely-broken code.
