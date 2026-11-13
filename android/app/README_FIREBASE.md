Flavor-specific Firebase setup

Why this matters

Your app uses Android product flavors (production, staging, development). Each flavor's final applicationId is the base `applicationId` plus the flavor's `applicationIdSuffix`.

Gradle's `google-services` plugin requires that the `google-services.json` file include a `client` entry with a matching `android_client_info.package_name` for the applicationId being built. If you build the development flavor whose applicationId is `com.obi.myalien.myalien.dev`, then the `google-services.json` must contain a client for that package name — otherwise Gradle fails with "No matching client found for package name ...".

Two ways to fix this (recommended)

1) Single combined `google-services.json` (same Firebase project)
   - In the Firebase Console for your project, add Android apps for each variant's applicationId:
     - com.obi.myalien.myalien (production)
     - com.obi.myalien.myalien.stg (staging)
     - com.obi.myalien.myalien.dev (development)
   - Optionally add SHA-1 / SHA-256 fingerprints if you use Phone Auth or App Check.
   - Download the `google-services.json` after registering these apps — the downloaded file will contain `client` entries for all of them.
   - Place the downloaded `google-services.json` at:
     `android/app/google-services.json` (replace the existing file)
   - Re-run your build.

2) Per-flavor `google-services.json` files (different Firebase projects per flavor)
   - In Firebase Console, create/register an Android app for each flavor in its corresponding project and download the `google-services.json` for each.
   - Place them in the flavor source directories (we created these for you):
     - `android/app/src/production/google-services.json`
     - `android/app/src/staging/google-services.json`
     - `android/app/src/development/google-services.json`
   - Gradle will pick the matching file for the built variant.

Quick workaround (not recommended for final builds)

- Build the production flavor only (it matches the current `android/app/google-services.json`):

```powershell
cd E:\Projects\MyAlien\myalien
flutter build apk --debug --flavor production -t lib/main_production.dart -v
```

This avoids changing Firebase config but doesn't help dev/staging flavors.

Notes / tips

- Phone authentication often requires SHA fingerprints. Add your debug/release SHA-1 and SHA-256 to the Android app in Firebase Console.
- After updating `google-services.json`, run a clean build to avoid Gradle cache issues:

```powershell
cd E:\Projects\MyAlien\myalien\android
.\gradlew.bat clean
cd ..
flutter build apk --debug -v
```

If you want, I can:

- Add your updated `google-services.json` (you can paste it here) and re-run the build for you.
- Or I can run the production-flavor build now to produce an APK quickly.

— End of README
