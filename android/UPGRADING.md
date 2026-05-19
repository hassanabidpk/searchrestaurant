# Android — Upgrade notes

This module was modernized from a 2016-era setup (Gradle 4.4 / AGP 3.1.4 /
`compileSdk 23` / Android Support Library) to a current toolchain.

> **Status: compiles pending verification.** These changes were made
> without an Android SDK available. The code/config is internally
> consistent and follows the standard AndroidX migration, but it has
> **not been built or run**. Open the project in Android Studio and do a
> Gradle sync + build to confirm before relying on it.

## What changed

### Build configuration
| Item | Before | After |
|------|--------|-------|
| Gradle wrapper | 4.4 | 8.10.2 |
| Android Gradle Plugin | 3.1.4 | 8.6.1 |
| `compileSdk` / `targetSdk` | 23 | 35 |
| `minSdk` | 15 | 24 |
| Java | (default 7/8) | 17 |
| Repos | `jcenter()` (shut down) | `google()`, `mavenCentral()` |
| Dep config | `compile` / `testCompile` (removed in Gradle 7) | `implementation` / `testImplementation` |
| Module namespace | `package=` in manifest | `namespace` in `app/build.gradle` |

### Dependencies
- `com.android.support:*:23.1.1` → AndroidX: `androidx.appcompat:appcompat:1.7.0`,
  `androidx.core:core:1.13.1`, `androidx.fragment:fragment:1.8.2`,
  `androidx.recyclerview:recyclerview:1.3.2`,
  `com.google.android.material:material:1.12.0`
- Retrofit `2.0.0-beta3` → `2.11.0` (+ `converter-gson:2.11.0`)
- Glide `3.6.0` → `4.16.0` (+ `annotationProcessor` compiler)
- `junit:junit:4.12` → `4.13.2`

### Source migration
- All `android.support.*` imports → `androidx.*` / `com.google.android.material.*`
  (3 Java files, 4 layout XMLs).
- Retrofit API changes in `RestaurantListActivity`:
  - `retrofit2.GsonConverterFactory` → `retrofit2.converter.gson.GsonConverterFactory`
  - `Response.isSuccess()` → `isSuccessful()`
  - `Callback.onResponse(Response)` → `onResponse(Call, Response)`;
    `onFailure(Throwable)` → `onFailure(Call, Throwable)`
- `AndroidManifest.xml`: removed `package`, added `android:exported="true"`
  on the launcher activity (required for `targetSdk` 31+).
- Deleted `ApplicationTest.java` — it extended `android.test.ApplicationTestCase`,
  removed in API 28+; it was an empty auto-generated stub.
- Glide call sites were left as-is: in Glide 4 `RequestBuilder` extends
  `BaseRequestOptions`, so `.centerCrop()` still chains. Verify at runtime.

## How to verify

```bash
cd android
# JDK 17 required for AGP 8.
./gradlew assembleDebug          # or: build a debug APK in Android Studio
./gradlew testDebugUnitTest      # runs ExampleUnitTest
```

A Gradle sync in Android Studio (Giraffe+) is the fastest smoke test.

## Known follow-ups / risks (not done here)

- **Theme:** `styles.xml` still uses `Theme.AppCompat.*`. Material 3
  components (`FloatingActionButton`, `AppBarLayout`) render best under a
  `Theme.Material3.*` / `Theme.MaterialComponents.*` parent. Left
  unchanged to avoid altering the app's appearance — revisit if you want
  the modern Material look.
- No instrumented tests remain (the only one was a broken stub). Add
  Espresso/AndroidX-test if instrumented coverage is wanted.
- `GoogleMaps`/API keys: unrelated to this upgrade; still placeholder.
- Versioned-catalog (`libs.versions.toml`) migration is optional; left
  as classic `build.gradle` to keep the diff reviewable.
