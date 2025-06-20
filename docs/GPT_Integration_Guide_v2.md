> ⚠️ UPDATE NOTE: This document has been synced to NurseOS v2 architecture.
> UPDATED: Added note-to-AI syncing, sentiment-tagging, and Firestore converter logic hooks.

...


# 🤖 NurseOS GPT Integration Guide – Shift Notes Assistant

## Purpose
This guide outlines how the NurseOS custom GPT is used to generate HIPAA-compliant, legally sound shift notes that nurses can review, edit, and save. This assistant enhances documentation speed, consistency, and professionalism during shift wrap-ups or care handoffs.

---

## 🎯 Use Case: GPT-Powered Shift Notes

Nurses can:
- Tap “New Shift Note” at the end of a shift
- Use a guided input screen to enter patient condition, care provided, issues observed
- Optionally allow the GPT to generate a fully drafted note
- Review and edit the note before saving

---

## 🧩 Data Flow

**Inputs to GPT:**
- Patient summary (name, age, pronouns, key flags)
- Most recent vitals
- Notes entered this shift
- Care tasks completed or pending
- Any tagged concerns or abnormal findings

**GPT Output:**
- Paragraph-form shift note
- HIPAA-safe language
- Optional formatting for review (e.g., bullet or SOAP style)

---

## 🛠 Structure (Example)

```json
{
  "noteType": "shift",
  "generated": true,
  "content": "Patient remained stable throughout shift. BP trended slightly high...",
  "generatedBy": "GPT",
  "createdAt": "2025-06-07T20:32:00Z",
  "createdBy": "nurse_001"
}
```

---

## 🧪 Local Development Setup

- Mock the GPT response using static files
- Place test notes in `/mock_data/mock_shift_notes.dart`
- Simulate delay for realism
- Allow toggle between “manual” and “auto-generated” entry modes

---

## 🚨 Safety + UX Considerations

- Nurse must always review the note before finalizing
- Add warning banner if AI-generated (`wasAiGenerated = true`)
- Log every GPT invocation for future audit trail

---

*This GPT is an assistant, not an author of record. Nurses retain final accountability.*
