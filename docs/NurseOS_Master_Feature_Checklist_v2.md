
# ✅ NurseOS v2 – Master Feature Checklist

This checklist replaces the legacy roadmap and provides detailed tracking of all architectural, UI, and domain-level features across NurseOS v2.

---

## 🧱 Core Architecture & Setup

- [x] Modular folder structure (`core/`, `features/`, `shared/`)
- [x] Riverpod v2 setup (Notifier + AsyncNotifier)
- [x] Firebase integration (Auth + Firestore)
- [x] Firestore rules for per-user safety
- [x] Dark/light theming system
- [x] GoRouter with auth refresh notifier
- [x] HIPAA visual/data practices

---

## 👥 Authentication & User State

- [x] Sign in/out flow
- [x] AuthController with keepAlive
- [x] UserModel with XP, badges, role
- [x] User-level Firestore sync
- [x] Firestore document hydration on login
- [x] Role-based access guards (nurse, admin)

---

## 🧩 User Preferences

- [x] DisplayPreferences model (freezed + enum)
- [x] Firestore-backed persistence
- [x] Toggle UI for display settings
- [x] Theme toggle (dark/light)
- [ ] Language preferences
- [ ] Notification preferences

---

## 🧑‍⚕️ Dashboard & Task System

- [ ] Task screen becomes gamified dashboard
- [ ] Display XP, level, and badges
- [ ] Show pending tasks
- [ ] Admin-only leaderboard (web only)
- [ ] Floating Action Button for new entries

---

## 👤 Patient Care Flow

- [ ] Patient list screen
- [ ] Patient detail screen with scrollable cards
- [ ] Vitals entry screen
- [ ] Vitals history + graph
- [ ] Head-to-toe assessment screen
- [ ] Care Plan screen
- [ ] Add Care Plan entry
- [ ] Note-taking with progressive disclosure

---

## 🎮 Gamification System

- [x] AbstractXpRepository (mock/live toggle)
- [ ] XP triggers from nurse actions only
- [ ] Badges triggered by shifts/tasks
- [ ] XP history or feedback microinteractions

---

## 🧪 Testing Suite

- [x] Unit tests for models and repos
- [x] Widget tests for screens
- [x] Golden tests for components
- [ ] Golden tests with type scaling
- [ ] Triggerable tests for XP/badge animations

---

## 🚀 Release & Ops

- [x] GitHub CI for analyze, test, format
- [x] Build runner cache clean automation
- [ ] Version tagging on releases
- [ ] Final QA & release checklist

---

# 📦 Status: Actively in Progress

Track each section weekly and update provider annotations, test coverage, and UI polish accordingly.
