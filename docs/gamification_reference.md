# NurseOS Gamification Reference

## 🎯 Purpose

Design a motivational system that supports nurse engagement and performance without adding pressure or competition to their daily workflow.

## 🧩 Core Gamification Elements

### 1. XP & Levels (Mobile App)

* **XP (Experience Points)**: Earned for completing tasks, logging notes, shift reviews.
* **Leveling System**: Visual level indicators to show long-term growth.
* **UI Locations**:

  * Dashboard: XP bar + current level summary
  * Profile: Full XP count, level breakdown, badge history

### 2. Badges (Coming Soon)

* Milestone-based (e.g., "10 shifts completed", "First patient handoff")
* Shown on profile only
* No public visibility or ranking

## 🚫 What We Avoid

* No public comparisons
* No leaderboard visibility on mobile
* No XP penalties

## 📊 Leaderboards (Admin Console Only)

* Available **only** via the NurseOS Web Admin Console
* Purpose: recognize top performers, identify patterns

### Leaderboard Views

* **Top Nurses This Week**
* **By Unit / Department**
* **All-Time XP Rankings**

### Filters / Options

* Date range
* Role / unit
* Shift type

### Firebase Setup

* **users/** collection:

  * `xp` (int)
  * `level` (int)
  * `unit`, `role` (optional for filtering)
* **leaderboards/** collection (optional precomputed rankings)

### Firestore Rule Example

```js
match /leaderboards/{doc} {
  allow read: if request.auth.token.role == 'admin';
}
```

## ✅ UX Notes

* Maintain a supportive tone
* Prioritize reflection, not competition
* Use badges and XP for encouragement only


<!-- v2.1 update – Jun 22 -->

## 🧠 Updated XP Hook Strategy

* XP should be incremented **within `save()` methods** of patient-related repositories.
* Ensure XP hooks are:
  - Triggered only in Firebase-backed mode
  - Disabled in mock mode (to prevent double-counting)
  - Testable via `MockXpRepository`

*XP tracking must remain invisible and motivational — not tied to scorekeeping or nurse evaluation.*
