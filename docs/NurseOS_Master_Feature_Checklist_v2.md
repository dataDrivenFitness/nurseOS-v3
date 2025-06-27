# ✅ NurseOS v2 – Master Feature Checklist

This checklist replaces the legacy roadmap. It tracks architecture compliance, mock/live coverage, UI polish, and feature testing across NurseOS v2.

---

## 🧱 Core Architecture & System

- [x] Modular folder structure (`core/`, `features/`, `shared/`)
- [x] Riverpod v2 setup (AsyncNotifier, Notifier)
- [x] Firebase integration (Auth + Firestore)
- [x] Firestore `.withConverter<T>()` usage only
- [x] Firestore rules for per-user and role safety
- [x] HIPAA-safe visual and data boundaries
- [x] Theme system (dark/light via `ThemeController`)
- [x] Env flags (`useMockServices`, `ENABLE_ANALYTICS`)

---

## 👥 Authentication & User State

- [x] Email/password login
- [x] AuthController (keepAlive: true)
- [x] `UserModel` with role, XP, and badges
- [x] Firestore-backed user document hydration
- [x] Role-based route and screen protection (nurse/admin)

---

## 👤 Profile & Preferences

- [x] Profile screen (name, avatar, email, role)
- [x] Edit profile form (safe save, photo upload)
- [x] User preferences (DisplaySettings model)
- [x] Dark mode toggle
- [ ] Language preferences
- [ ] Notification preferences
- [x] Firestore-backed persistence of preferences

---

## 🧑‍⚕️ Core Care Flow

- [ ] Patient list screen
- [ ] Patient detail screen with scrollable cards
- [ ] Vitals entry (with FAB)
- [ ] Vitals history with graph and progressive disclosure
- [ ] Head-to-toe assessment
- [ ] Shift schedule screen with drag/drop interaction
- [ ] Shift review with auto-summarized notes (GPT)
- [ ] Care Plan read-only view
- [ ] Visit notes (HIPAA-safe, linked to shift + patient)
- [ ] EVV check-in with GPS and timestamp

---

## 🤖 GPT + AI Assistant

- [x] GPT-powered shift notes
- [x] Editable AI-generated text with `wasAiGenerated`
- [x] Audit log for GPT usage
- [ ] Care plan drafting (Phase 7)
- [ ] Note summarization via vector context (Phase 7)
- [ ] AI trend detection (Phase 7)

---

## 🎮 Gamification System

- [x] `AbstractXpRepository` (mock/live)
- [x] XP increment on nurse actions (e.g. note save)
- [ ] XP history or microinteractions
- [ ] Badge system (triggers on milestones)
- [ ] Admin-only leaderboard (web only)

---

## 🧪 Testing Suite (Unit, Widget, Golden)

- [x] Unit tests for all repositories/controllers
- [x] Widget tests for screen interactions
- [x] Golden tests for visual states
- [ ] Golden tests for type scaling (`MediaQuery.textScaleFactor`)
- [ ] Triggerable golden tests for XP animations and FABs
- [ ] Golden test baseline for NurseScaffold layout
- [ ] AI-generated content test flows (with confirm/reject states)

---

## 🧼 UI & UX Compliance

- [x] Type scaling support across all `Text()`
- [x] Progressive disclosure (Vitals, Notes)
- [x] FAB support in task-like screens (Vitals, Notes)
- [x] Theme-safe (light/dark)
- [x] Animated feedback (submit, refresh, success)
- [ ] Unified loading state shimmer across screens

---

## 🚀 Release & Ops

- [x] GitHub CI (analyze, test, golden, build)
- [x] Version tagging with `tool/bump_version.sh`
- [x] Firebase emulator coverage
- [ ] Final QA + release signoff checklist
- [x] Secure build: obfuscation, split debug info, CI lint rules
- [x] `.env.dart` enforcement for `useMockServices`

---

# 📦 Release Track: In Progress (v2.2.x+)
Check this file weekly. Mark new features with test, audit, or visual blockers. Sync with `Feature_Dev_Guide_v2-2.md` and `ARCHITECTURE.md` as needed.
