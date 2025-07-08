
# Test Guidelines for NurseOS Router + Views

---

## Golden Tests

Golden tests must render:
- [x] Default screen state
- [x] FAB visible if defined
- [x] Dark mode toggle
- [x] Animated states (use tester.pump() + duration)

---

## Widget Tests

All views must include:
- [x] UI visibility for main elements
- [x] User flow from tap to screen transition
- [x] No direct async calls — test via providers

---

## Routing Tests

Use mockRouter + mockObserver:
- [x] Test pushNamed + back button
- [x] Check redirects
- [x] Validate args on push

---

## Text Scaling Tests

Use MediaQuery with:
- textScaleFactor: 0.8
- textScaleFactor: 1.0
- textScaleFactor: 1.3
- textScaleFactor: 2.0

Each must maintain:
- [x] Layout stability
- [x] No overflow
- [x] Min font size respected

---

## Microinteractions

If a view uses `animation_tokens.dart`:
- [x] Animation must be test-triggerable
- [x] Golden must capture animated state
- [x] Widget test must assert transition

---
