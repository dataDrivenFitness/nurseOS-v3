
# NurseOS UX Recommendations v2

Design + Interaction Guidelines for all new feature development

---

## ✅ Type

- Use MediaQuery to scale all Text()
- Test with 0.8x, 1x, 1.3x, 2x sizes
- Minimum text size: 13px
- Maximum line length: ~72 chars

---

## ✅ Buttons

- Use FilledButton for primary
- Use OutlinedButton or TextButton for secondary
- Use SegmentedButton for filters or modes

---

## ✅ Icons

- Use cupertino_icons or Material symbols
- Minimum tap target: 48px
- Icons must support dark mode

---

## ✅ Layout

- Use Slivers in scrollable lists
- Use Cards for patient-level items
- Prefer 8pt spacing scale

---

## ✅ Animations

- Use animation_tokens.dart for microinteractions
- Transition patterns: fade, slide, scale
- Avoid bouncing or long delays

---

## ✅ Floating Action Button

- Use only where nurse is initiating data
- Show FAB on Vitals, Notes, Checklists
- Hide FAB on read-only views

---

## ✅ Progressive Disclosure

- Use for Notes, History, Alerts
- Collapse long text under "... more"
- Avoid expanding >3 items at once

---

## ✅ Alerts

- Show critical alerts inline (no popups)
- Use color tokens from theme
- Animate appearance with fade-in or scale-in

---

## ✅ Theming

- All screens must support light/dark
- Use core/colors.dart for palette
- Do not hardcode hex values

---
