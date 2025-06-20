> ⚠️ UPDATE NOTE: This document has been synced to NurseOS v2 architecture.
> UPDATED: Linked audit-log hooks, clarified offline-first strategies, and added notes on biometric protection in v2 blueprint.

...

# NurseOS HIPAA Readiness Checklist (Revised)

## 🔒 On-Device Protections
- [ ] Require biometric auth (Face ID / Touch ID) before access
- [x] Blur screen when app is backgrounded (`FLAG_SECURE`)
- [ ] Disable screenshots / screen recording on mobile
- [ ] Avoid displaying PHI in notifications or app switcher
- [ ] Auto-lock after inactivity timeout (Phase 3+)

## ☁️ Cloud Security (Firebase or Supabase)
- [x] Encrypted data at rest and in transit (Firebase default)
- [ ] Role-based Firestore security rules per shift assignment
- [ ] Logs of all reads/writes to sensitive data (Phase 4)
- [ ] Limit Firestore rules to logged-in, authorized nurses only
- [ ] Firebase storage rule: reject uploads with `application/pdf`, `image/jpeg` outside `/patients/`

## 🧪 Development Discipline
- [x] useMockServices disables Firebase in dev
- [x] No real patient data or PHI in dev/testing
- [ ] Firebase Auth restricted to demo accounts (e.g., `@demo.com`)
- [ ] Lint rule or CI check prevents pushing PHI-like literals
- [ ] Required mock-only mode for widget tests and local emulators

## 🧠 AI Usage and GPT Notes
- [ ] Add `wasAiGenerated`, `createdBy`, and `createdAt` to all AI-generated notes
- [ ] Display banner in UI for AI-generated content
- [ ] Require nurse review/edit before saving any AI-generated text
- [ ] Log all GPT actions (generation, edits, saves) with timestamp and user UID

## 👩‍⚕️ Nurse Confidence Design
- [ ] Provide “My Actions” screen to view personal audit trail
- [ ] Hide low-risk patients unless toggled
- [ ] Explicit indicators for synced/unsynced state (e.g., 🟢 / 🔴 chips)
- [ ] Suppress names or patient pills unless risk > low
- [ ] Inline audit history for each shift note or care entry

## 🔍 Logging and Audits (Phase 4+)
- [ ] Log logins, profile access, patient views
- [ ] Log note edits, GPT usage, Firebase writes
- [ ] Nurse-visible “Access Logs” page
- [ ] Admin-accessible audit export (CSV or Firestore snapshot)

---

> This checklist enforces HIPAA readiness, ethical AI usage, and trust-focused UX design — aligned with NurseOS architecture and mock-first development flow.
