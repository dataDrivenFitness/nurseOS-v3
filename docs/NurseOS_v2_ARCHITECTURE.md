# NurseOS v2 Architecture Blueprint

## 1 Overview
A lightweight, test‑driven rebuild of NurseOS that follows a Clean Layered
architecture, enforces HIPAA‑safe practices, and prevents future drift.

## 2 Layered Architecture
```
UI Widgets ─┬─ Riverpod Feature Notifiers ─┬─ Repositories ─┬─ Data Sources
            │                            │                 └─ Firebase / REST
            │                            └─ Domain Models (Freezed)
            └─ Design‑System Components
```

## 3 Folder Structure
```
lib/
  core/        ← cross‑cutting (env, error, theme)
  features/    ← one folder per vertical slice
  shared/      ← small reusable widgets & util
test/           ← unit, widget & golden tests
```

## 4 Naming Conventions
* Models: `SomethingModel`
* Providers: `somethingProvider`
* AsyncNotifiers: `SomethingController`
* Screens: `SomethingScreen`

## 5 State Management
* **Riverpod** everywhere — no `setState` in production widgets.
* `AsyncValue` guards all async work; UI must handle `loading`, `error`, `data`.

## 6 Data Layer
* Repositories return *typed* models, never raw Maps.
* Firestore is accessed via `withConverter`, one collection per aggregate root.

## 7 Error Handling Strategy
* All repos wrap calls in `Result<T, Failure>`.
* UI logs to Sentry and shows friendly retry tiles.

## 8 Theming & Design System
* Central `AppColors`, `SpacingTokens`, typography scale.
* Dark theme first, rely on Theme extensions—no literal `Colors.*`.

## 9 Testing Strategy
* Unit tests for every repository & converter.
* Widget tests for every screen.
* Golden tests for reusable components.
* Coverage target ≥ 30 % before production release.

## 10 CI / CD & Tooling
* GitHub Action: `flutter pub get`, `flutter analyze`, `flutter test`.
* Pre‑commit hook: `dart format` + `flutter analyze`.
* `very_good_analysis` or equivalent ruleset.

## 11 Guardrails to Prevent Drift
1. Each PR must add/modify at least one test.
2. No runtime type casts.
3. Weekly architecture review against this doc.
4. Major decisions captured in `/docs/decisions/`.

## 12 Roadmap Implementation Checklist

### Phase 0 – Safety Net (💻 ≈ 30 min)
- [ ] Tag current commit: `git tag stable-pre-v2`
- [ ] Push tags: `git push origin --tags`
- [ ] Zip & archive working directory locally

### Phase 1 – Branch & Scaffold (🗂 ≈ 1–2 hrs)
- [ ] Create branch: `git checkout -b v2`
- [ ] Add empty folders (`core`, `features`, `shared`, `test`)
- [ ] Extend `.gitignore`, add `.env.example`

### Phase 2 – Tooling & CI (⚙️ ≈ 4 hrs)
- [ ] Add `analysis_options.yaml`
- [ ] Configure GitHub Action (analyze + test)
- [ ] Install pre‑commit hook

### Phase 3 – Port Essentials (📦 ≈ ½ day)
- [ ] Copy Freezed models & theme tokens
- [ ] Implement baseline Patient repository contract + mock

### Phase 4 – First Vertical Slice (🖥 ≈ 1–2 days)
- [ ] Build *Patient List → Patient Detail → Vitals Entry* flow
- [ ] Wire via Riverpod `AsyncNotifier`
- [ ] Add unit & widget tests

### Phase 5 – Iterate Feature‑by‑Feature (♻️ ongoing)
- [ ] Vitals entry workflow (Firestore)
- [ ] Auth flow with persistent login
- [ ] Profile editing & photo upload
- [ ] Dashboard & tasks aggregation

### Phase 6 – Legacy Decommission (📁 after parity)
- [ ] Archive `stable-pre-v2` branch
- [ ] Update README & docs for v2
- [ ] Move obsolete docs to `/legacy`
