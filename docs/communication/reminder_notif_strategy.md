# 📣 NurseOS v2 – Reminder & Notification Strategy

_Last updated: 2025-06-27_

This document defines **when**, **why**, and **how** NurseOS v2 should send reminders or push notifications. It supports HIPAA compliance, user-centric UX, and modular implementation via Riverpod.

---

## ✅ Notification Eligibility Criteria

### 1. 🧠 Clinical Relevance
Notify only when:
- Timely nurse action is required
- No redundant alert already exists in the UI
- Event cannot be silently queued or batched

**Examples to Notify:**
- End-of-shift summary required
- No vitals recorded in last X hours
- Missed care task due today

**Examples to Avoid:**
- Informational events (“Note saved”)
- Tasks already shown as overdue in app UI
- Repeat alerts within short windows

---

### 2. 🔐 HIPAA + UX Constraints
- 🚫 No PHI in notification text or payload
- ✅ Use general phrasing (e.g., “You have a pending task”)
- 🔒 Detailed context only shown **after app unlock**
- ⚠️ Avoid visual alerts on app switcher (via `FLAG_SECURE`)

---

### 3. 🛠 App Context Conditions
- Nurse must be **on shift**
- Notification must not have been **recently acknowledged**
- Device must have **active FCM token** or fallback to local queue
- User must still be **assigned to patient or task**

---

## 🧠 ReminderEligibilityEngine

A utility class to centralize logic:

```dart
class ReminderEligibilityEngine {
  bool shouldNotify({
    required NurseProfile profile,
    required ReminderModel reminder,
    required AppContext context,
  }) {
    if (!profile.isOnShift) return false;
    if (reminder.acknowledged) return false;
    if (!reminder.requiresAction) return false;
    if (reminder.lastSent != null &&
        DateTime.now().difference(reminder.lastSent!) < Duration(minutes: 15)) {
      return false;
    }
    return true;
  }
}
```

---

## 🔄 Implementation Plan

| Phase     | Task                                                                 |
|-----------|----------------------------------------------------------------------|
| Phase 4–5 | Add `ReminderModel`, `AbstractNotificationService`, `MockController` |
| Phase 6   | Add `ReminderEligibilityEngine`, FCM token registration logic        |
| Phase 7+  | Add Firebase Cloud Function triggers + XP tie-ins for reminders      |

---

## 🔍 Audit Trail Requirements
All notifications must be logged:

```json
/logs/notifications/{logId} {
  "event": "reminder_sent",
  "recipient": "nurse_001",
  "reminderId": "abc123",
  "timestamp": "2025-06-27T10:00:00Z",
  "wasPush": true
}
```

---

## 🧪 Testing Requirements
- ✅ Unit test: `ReminderEligibilityEngine`
- ✅ Widget test: Reminder create/edit screen
- ✅ Golden test: reminder card with time/frequency state
- ✅ Emulator test: FCM mock and fallback handling
- ✅ HIPAA test: content review, secure display, screen blur

---

> This guide ensures reminders are respectful, meaningful, and safe. Nurses stay informed — never overwhelmed.
