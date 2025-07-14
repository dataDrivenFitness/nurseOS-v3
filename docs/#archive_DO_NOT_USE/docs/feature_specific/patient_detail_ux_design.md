# NurseOS v2 – Patient Detail Screen Interaction Design

**Date:** 2025-06-25  
**Scope:** Horizontal section previews, FAB actions, and Ghost Cards for progressive disclosure  
**Author:** NurseOS Dev Buddy

---

## 🧠 UX Strategy

### Key Goals
- Progressive disclosure (only show what’s necessary)
- Clear separation of additive actions (XP-triggering)
- Minimal screen clutter for mobile-first use
- Fast scanning for high-tempo clinical environments

---

## 🧩 Section Interaction Design

### 🔹 Section Layout (Vitals, Notes, etc.)
- Horizontally scrollable card preview (summary only)
- Tapping a preview card opens a detailed view (modal or screen)
- **Final card** in scroll view is a `GhostCard` with label: **“View all”**
- GhostCard fades in, styled as subtle affordance for full history

#### Example:
```
Vitals
[ BP: 120/80 ] [ BP: 118/72 ] [ GhostCard: View all vitals ]
```

---

### 🔹 Detail View (After Tapping a Card)
- Opens full card with complete data
- Optionally includes:
  - Edit / Delete buttons
  - Timestamp / author meta

---

## ➕ FAB Strategy

### Global FAB (Profile/Tasks screens only):
- Opens speed dial with:
  - Add Vitals
  - Add Notes
  - Add Assessment
  - Add Care Plan

### Section FAB (inside full detail views only):
- Single-action FAB
- Contextual: e.g., `Add Vitals`
- Tied to XP gain via `AbstractXpRepository`

---

## 🧪 Implementation Notes

- Use `animation_tokens.dart` for GhostCard fade/slide
- GhostCard implemented as tappable `Card()` with subdued style
- FAB uses `FloatingActionButton.extended` or `SpeedDial` (custom widget)
- Each section’s preview list must account for a trailing GhostCard

---

## ✅ UX Benefits

| UX Element           | Benefit |
|----------------------|---------|
| GhostCard at end     | Progressive, non-intrusive CTA |
| FAB in detail view   | Only shows when contextually useful |
| Card-as-button       | Familiar and tappable affordance |
| No inline “Add” noise| Reduces clutter in preview state |

---

## 📁 Suggested File Locations

- `lib/shared/widgets/ghost_card.dart`
- `lib/features/patient/presentation/widgets/fab_add_menu.dart`
- `lib/features/vitals/presentation/screens/vitals_history_screen.dart`
