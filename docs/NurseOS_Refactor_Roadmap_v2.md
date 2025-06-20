> ⚠️ UPDATE NOTE: This document has been synced to NurseOS v2 architecture.
> UPDATED: Trimmed sections that duplicated new ARCHITECTURE.md (e.g., CI policies, AsyncValue handling). Kept timeline and sequencing logic.

...

# NurseOS Refactor Roadmap (v2 Branch)

> **Purpose:** Provide an end‑to‑end, step‑level plan for migrating NurseOS from the current architecture to the v2 feature‑first structure while continuously maintaining a working build. This roadmap is structured for easy progress tracking and strict drift prevention across future conversations.

---

## 1. Guiding Principles

| Principle                 | Description                                                               |
| ------------------------- | ------------------------------------------------------------------------- |
| **Dual‑Branch Safety**    | `main` remains production‑ready; `v2` hosts all refactor work.            |
| **Incremental Migration** | One feature moves at a time—app must compile after every merge.           |
| **Decision Anchoring**    | Every architectural change gets a short entry in `docs/DECISIONS.md`.     |
| **CI Gatekeeping**        | No PR merges unless **analysis**, **tests**, and **format** pass.         |
| **Drift Prevention**      | Use hand‑off summaries and this roadmap as the canonical scope reference. |

---

## 2. High‑Level Timeline *(7 weeks total, flexible)*

| Sprint       | Duration | Theme                | Exit Criteria                                                                |
| ------------ | -------- | -------------------- | ---------------------------------------------------------------------------- |
| **Sprint 0** | 2 days   | Pre‑Flight & Tooling | `v2` branch; CI pipeline green; Freezed + folder skeleton ready.             |
| **Sprint 1** | 1 week   | Core Foundations     | Models ▶️ `freezed`; first `AsyncNotifier`; global error surface.            |
| **Sprint 2** | 1.5 w    | Patient Module       | All patient UI, state, repo in `features/patient`; tests & empty states.     |
| **Sprint 3** | 1.5 w    | Vitals & Tasks       | Vitals & tasks fully migrated; mock & Firestore parity.                      |
| **Sprint 4** | 1 week   | Navigation Layer     | Introduce GoRouter (deep‑link deferred but plumbing ready).                  |
| **Sprint 5** | 1 week   | QA / A11y / Perf     | ≥80 % lighthouse‑style a11y score; widget tests >50 % coverage; const sweep. |

*Time is elastic (you’re solo), but milestones anchor discussion and prevent scope creep.*

---

## 3. Branch & CI Policy

1. **Branches**
   - `main`: hot‑fix only; must build & run.
   - `v2`: protected; all feature PRs target this.
2. **PR Template Checklist**
   - [ ] Linked roadmap task ID.
   - [ ] Unit/widget tests updated or added.
   - [ ] `DECISIONS.md` updated (if architecture changed).
   - [ ] CI green (`flutter analyze`, `flutter test`, `flutter format`).
3. **CI Workflow** (`.github/workflows/flutter.yml`)
   ```yaml
   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: subosito/flutter-action@v3
         - run: flutter pub get
         - run: flutter analyze --no-pub
         - run: flutter test
         - run: flutter format --set-exit-if-changed .
   ```

---

## 4. Sprint‑Level Task Breakdown

### Sprint 0 – Pre‑Flight (Task IDs: 0.x)

| ID | Task | Details | Done‑When |
|----|------|---------|-----------|
| **0.1** | Create `v2` branch | `git checkout -b v2` | Branch pushed to remote. |
| **0.2** | Add CI pipeline | Copy workflow above | CI run succeeds on `v2`. |
| **0.3** | Pin tool versions | Add `fvm_config.json` (Flutter 3.22) | `fvm use` works locally & CI. |
| **0.4** | Folder Skeleton | Create `/features/`, move readmes | App still compiles. |
| **0.5** | Integrate `freezed` | Add deps, run `build_runner` | `PatientModel` generated. |

### Sprint 1 – Core Foundations (Task IDs: 1.x)

| ID | Task | Details | Done‑When |
|----|------|---------|-----------|
| **1.1** | Migrate `PatientModel` & `VitalsModel` to `freezed` | Remove manual `fromMap`/`copyWith` | Tests pass. |
| **1.2** | Introduce first `AsyncNotifier` | Convert `vitalsProvider` | UI read/write unchanged. |
| **1.3** | Global Error Surface | Add `ProviderObserver` + snackbar | Error logged & visible. |
| **1.4** | Const/Lints Sweep | `dart fix --apply` + manual sweep | Analyze shows <10 const‑lint hits. |
| **1.5** | Decision Log template | Create `docs/DECISIONS.md` | First entry for `freezed`. |

### Sprint 2 – Patient Module (Task IDs: 2.x)

| ID | Task | Details | Done‑When |
|----|------|---------|-----------|
| **2.1** | Move patient files into `features/patient/` | UI, state, repo | Imports updated. |
| **2.2** | Create `PatientRepository` interface | Implement Firestore + Mock | Switch via Provider override. |
| **2.3** | Widget & Golden Tests | `PatientCard` + list empty state | CI passes tests. |
| **2.4** | Add empty/error UI | Show placeholder when no patients | UX verified. |
| **2.5** | Remove legacy files | Delete old patient paths | `git status` clean. |

### Sprint 3 – Vitals & Tasks (Task IDs: 3.x)

*(mirror table similar to Sprint 2; omitted for brevity—fill during Sprint 2 planning)*

### Sprint 4 – Navigation Layer (Task IDs: 4.x)

| ID | Task | Details | Done‑When |
|----|------|---------|-----------|
| **4.1** | Add GoRouter dependency | Configure root router (deep‑link off) | App navigates via GoRouter. |
| **4.2** | Tab‑level sub‑stacks | Each bottom‑nav tab retains history | Back stack behaves as expected. |
| **4.3** | Redirect auth guard | `/login` guard for unauth users | Manual test passes. |

### Sprint 5 – QA / A11y / Performance (Task IDs: 5.x)

| ID | Task | Details | Done‑When |
|----|------|---------|-----------|
| **5.1** | a11y audit | Use Flutter semantics debugger | ≥ 90 % issues fixed. |
| **5.2** | Widget test coverage | Target >50 % lines | `flutter test --coverage` threshold met. |
| **5.3** | Performance pass | Add `const`, measure build time | Hot‑reload <1.5 s on mid‑tier Mac. |

---

## 5. Progress Tracking Tools

### 5.1 Roadmap Kanban (suggested columns)

`Backlog → In Progress → In Review → Done` (use GitHub Projects or Trello). Every task ID links to its card.

### 5.2 Burndown Table *(update manually each Sunday)*

| Week | Planned Tasks | Completed | % Done |
| ---- | ------------- | --------- | ------ |
| 0 | 5 |  |  |
| 1 | 5 |  |  |
| … | … | … | … |

### 5.3 Handoff Prompt Template

> **✅ Done:** <brief>
> **🔧 Next:** <tasks/IDs>
> **⚠️ Pending:** <risks>

Copy this into ChatGPT at the end of each working session to lock state.

---

## 6. Drift Prevention & Conversation Discipline

1. **Always cite task IDs** when asking ChatGPT to modify code.
2. **Ask for original file** before permitting a GPT‑driven rewrite.
3. **No scope creep** without adding a new task row and updating timeline.
4. **Weekly summary**: Every Sunday, post the burndown update + handoff prompt.

---

## 7. Open Questions (capture & resolve before the next sprint)

| ID | Question | Owner | Deadline |
| -- | -------- | ----- | -------- |
| Q1 | Which Firebase plans & security rules version? | You | Sprint 0 end |
| Q2 | Exact a11y target metrics (contrast, font scaling)? | You | Sprint 4 start |

---

> **Next Action:** • Execute **Task 0.1** – create & push `v2` branch. • Ping ChatGPT with the handoff prompt after completion to initiate **Task 0.2**.
