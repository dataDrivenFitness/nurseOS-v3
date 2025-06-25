# 🏗️ NurseOS v2 – Build & Release Playbook  
_Last updated: 24 Jun 2025_

A concise, one-page reference for **local builds**, **CI/CD**, and **release-hardening**.  
Paste this whole block into `NurseOS_v2_ARCHITECTURE.md` (CI/CD section) or keep it as  
`docs/build_pipeline_overview.md`.

---

## 1 · Local developer loop (≤ 60 s incremental)

| Step | Command | Purpose |
|------|---------|---------|
| Bootstrap packages | `melos bootstrap` | One-time fetch for the mono-repo. |
| Code-generation (watch) | `dart run build_runner watch --delete-conflicting-outputs` | Keeps Freezed / Riverpod outputs fresh. |
| Lint & format | `flutter analyze && dart format .` | Zero lint errors, zero warnings. |
| Tests + coverage | `flutter test --coverage` | Runs unit, widget, and golden suites. |
| Local Firebase | `firebase emulators:start --import=./emulator-data` | PHI-safe backend on your laptop. |
| Hot-restart run | `flutter run --flavor mock -d <device>` | Stub repos; instant reload. |

> **Tip:** Turn on *save-on-focus-loss* in your IDE—`build_runner watch` + hot-restart gives ~2 s feedback.

---

## 2 · Branching & versioning

* **`dev`** – default target for feature PRs.  
* **`main`** – always release-candidate quality (all CI checks required).  
* **Tags** – `v2.x.y+build` created automatically by CI.

Version bump helper:

./tool/bump_version.sh <major|minor|patch>
Updates pubspec.yaml, Android versionCode, iOS Marketing Version, commits with a ci(version): … message.

## 3. CI/CD pipeline (GitHub Actions)
Job	Runner	Key tasks
lint	ubuntu-latest	flutter analyze --fatal-infos
tests	macos-latest	Matrix: { iOS sim, Android emul } → flutter test --flavor mock
goldens	ubuntu-latest	Headless Skia render, uploads diffs as artefacts.
build-apk	macos-latest	flutter build apk --flavor prod --obfuscate --split-debug-info=build/symbols
build-ipa	macos-latest	flutter build ipa --flavor prod --export-options-plist=ios/exportOptions.plist
upload	macos-latest	Fastlane → Play Internal + TestFlight.
mob-sf	ubuntu-latest	Static scan; fails on non-FIPS libs.
docs-drift	ubuntu-latest	Ensures ARCHITECTURE / Guides updated in same PR.

Secrets (GOOGLE_SERVICE_JSON, APP_STORE_CONNECT_KEY, …) live in repo-level encrypted GitHub secrets and rotate quarterly.

## 4. Build flavours
Flavour	Bundle ID	Firebase project	Analytics	Notes
mock	com.nurseos.v3.mock	none	off	Offline demos with stub data.
staging	com.nurseos.v3.stg	nurseos-stg	on	HIPAA BAA in place; QA data only.
prod	com.nurseos.v3	nurseos-prod	on	Live PHI; strict rules & monitoring.

lib/core/env/ contains Env.*.dart files code-generated from env/*.json.

## 5. Release-build hardening
--obfuscate --split-debug-info — symbols archived to private S3.

Min-SDK 23 (Android) — enforces TLS 1.3 & file-based encryption.

Static scan (MobSF) — CI fails if native libs aren’t FIPS-compatible.

dart-define flags — ENABLE_ANALYTICS=false during HIPAA audits.

Sentry & Crashlytics enabled only for staging and prod.

## 6. Post-build smoke & regression
Detox end-to-end — logs in with tester@ account, runs Vitals, Notes, dark-mode toggle.

Device golden diff — image-based diff on real devices to catch Skia flag changes.

Promotion-on-green — CI auto-promotes from Play Internal → Closed and TestFlight “Nurse QA”.

##7. One-button local script (tool/devup)

#!/usr/bin/env bash
set -e
melos bootstrap
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test --coverage
firebase emulators:start &
EMU_PID=$!
trap "kill $EMU_PID" EXIT
flutter run --flavor mock -d $(flutter devices | head -n1 | cut -d'•' -f2)
Make it executable:

chmod +x tool/devup
Run ./tool/devup after every fresh pull; it handles everything from code-gen through hot-restart.

## 8. Change-management checklist
✅	Step
☐ Updated NurseOS_v2_ARCHITECTURE.md CI/CD section	
☐ Added this file to repo & linked from architecture doc	
☐ Inserted flavour matrix into Firebase_Integration_Strategy.md	
☐ Ticked new rows in Master Feature Checklist	
☐ Created .github/workflows/build.yml matching job matrix	
☐ Committed tool/devup script with exec bit	

Once these boxes are checked, the build pipeline is fully documented and enforceable.