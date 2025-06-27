# 🗺️ NurseOS v2 Refactor Roadmap

This roadmap guides the test-driven rebuild of NurseOS v2 with modular architecture, HIPAA-safe practices, and gamified UX.

---

## ✅ Phase 0 – Safety Net

- [x] Tag current v1 commit
- [x] Export full backup archive
- [x] Snapshot user schema + Firestore structure

---

## 🧱 Phase 1 – Scaffold

- [x] Create `v2` branch
- [x] Establish folder structure (`core/`, `features/`, `shared/`)
- [x] Add `.env` + firebase config stubs

---

## 🧪 Phase 2 – Tooling

- [x] Lints (`very_good_analysis`)
- [x] CI actions: analyze, test, format
- [x] Pre-commit hook
- [x] Type-scaling golden test scaffolds

---

## 🚀 Phase 3 – Core System Port

- [x] Migrate user/auth model
- [x] Set up Riverpod + FirebaseAuth integration
- [x] ThemeController + dark mode toggle
- [x] DisplayPreferences model + Firestore sync
- [x] FontScaleController with app-wide MediaQuery override

---

## 🔁 Phase 4 – Vertical Feature Slice

- [ ] Patient list screen
- [ ] Patient detail screen
- [ ] Vitals entry screen
- [x] Per-nurse toggles respected across screens

---

## 🎮 Phase 5 – Feature Expansion

- [ ] Tasks + XP gamification
- [ ] Dashboard: pending tasks + levels
- [ ] Shift timing, session badge trigger
- [ ] Note-taking with progressive disclosure
- [ ] Shift schedule screen with drag-and-drop UI
- [ ] EVV check-in with GPS or selfie
- [ ] Progress note entry per visit

---

## 🧼 Phase 6 – Decommission & Cleanup

- [ ] Archive v1 code
- [ ] Lock Firestore v1 rules
- [ ] Promote v2 in all deploy targets
- [ ] Final QA + Release

---

## 🤖 Phase 7 – LLM Assistant + AI Copilot (Planned)

- [ ] Enable Firestore-to-GPT note generation endpoints
- [ ] Integrate Chroma/Qdrant vector database for patient context retrieval
- [ ] Support summarization of vitals and shift notes
- [ ] Draft care plans via templated GPT prompts
- [ ] Cache AI outputs in Firestore with audit metadata
- [ ] Display AI-generated content with editable review mode

---

# ✅ Let's build something nurses deserve.
