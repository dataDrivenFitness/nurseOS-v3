
# Gamification Reference – NurseOS v2

> Defines XP, badges, levels, and enforcement logic for gamification features within NurseOS v2.

---

## 🎯 Goals

- Encourage consistent documentation and patient care
- Reward timely task completion and app engagement
- Create healthy competition (admin-only visibility)

---

## ✅ Core Concepts

### 🧠 XP (Experience Points)

- Only nurse-initiated actions can trigger XP
- XP stored under `users/{uid}.xp` and updated via Cloud Functions

#### Example Triggers:
| Action                   | XP |
|--------------------------|----|
| Submit vitals            | 5  |
| Add patient note         | 10 |
| Complete checklist item  | 3  |
| Resolve alert            | 15 |
| Submit patient summary   | 20 |

---

### 🏅 Badges

Badges represent milestones or rare behaviors. Stored in:
```
users/{uid}/badges/
```

#### Examples:
- `earlyBird` – 3+ actions before 8 AM for 5 days
- `sharpScribe` – 100 notes submitted
- `calmResponder` – 25 alerts resolved without escalation

---

### 🧱 Firestore Structure

```plaintext
users/
  {uid}/
    xp: int
    level: int
    badges/
      {badgeId}: { awardedAt: Timestamp }

leaderboards/
  weekly/
    {weekId}/
      {uid}: { xp: int }
```

> Leaderboard is read-only on mobile. Visible only in admin portal.

---

## 🛠️ Abstract XP Repository

Use `AbstractXpRepository` with mock/live implementation.

```dart
abstract class AbstractXpRepository {
  Future<void> grantXp(String userId, XpAction action);
}
```

- Live version uses HTTPS Callable Functions (`functions.grantXp`)
- Mock version supports `useMock` toggle

---

## 💥 Constraints

- XP logic is server-side only
- No XP for system-generated events or retries
- Badge logic validated daily via scheduled Cloud Function

---

## ✅ Testing Rules

- All XP triggers must be testable via unit test and UI simulation
- Gamified UI elements (e.g., badge popup) must have golden test
- XP animation uses `animation_tokens.dart` and is test-triggerable

---

## 🚫 Anti-Patterns

- ❌ No XP updates from client-side logic
- ❌ Don’t display leaderboard on mobile

---
