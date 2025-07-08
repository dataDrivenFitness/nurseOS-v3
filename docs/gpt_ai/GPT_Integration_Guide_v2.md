
# GPT Integration Guide – NurseOS v2

> Guidelines for embedding OpenAI GPT features in NurseOS while maintaining HIPAA-aligned practices.

---

## ✅ Use Cases

- **Documentation Drafting**: Summarize notes or create shift summaries
- **Education**: Answer clinical questions based on public info
- **Task Suggestions**: Recommend follow-up actions (non-binding)

---

## 🚫 Prohibited Use

- ❌ Never send PHI to GPT APIs
- ❌ No direct clinical decision support
- ❌ No diagnostic or medication suggestions

---

## 🔐 Privacy & Compliance

- Use OpenAI’s API via a HIPAA-reviewed proxy layer
- All requests must be de-identified before submission
- Responses are cached with audit metadata

---

## 📁 File Structure

```
lib/features/gpt/
  services/
    gpt_proxy_service.dart
  models/
    gpt_prompt.dart
  ui/
    smart_suggestion_box.dart
```

---

## 📦 Prompt Structure

```dart
class GptPrompt {
  final String context;
  final List<String> bullets;
}
```

- Prompts constructed in the UI layer, filtered by role
- Content is non-identifiable by design

---

## 🔄 Request Pattern

```dart
final result = await ref.read(gptProvider).generateSummary(prompt);
```

- Uses `AsyncNotifier`
- Wrapped in `.when()` for all UI output

---

## 🧪 Testing GPT Features

- Mock provider must return canned responses
- Golden tests for all smart suggestion UIs
- Test all failure states (timeouts, bad responses)

---

## 🎨 UX Requirements

- Progressive disclosure for AI-generated text
- User must confirm before saving AI output
- Explainability tooltips required for suggestions

---

## 🧩 Integration Rules

- No GPT logic in `core/`
- Providers live under `features/gpt/`
- Use environment toggles to disable GPT in `mock` or `audit` modes

---

## 🔁 Logging

- All prompts logged to `logs/gpt_prompts/`
- Include:
  - `userId`
  - `timestamp`
  - `promptHash`
  - `feature` (e.g., notes_summary)

---

## 🚫 Anti-Patterns

- ❌ Don’t use `text-davinci-003` or legacy models
- ❌ No prompt-building in repositories
- ❌ No caching of PHI-containing content

---

## 🧠 Future LLM Assistant Architecture

This section outlines the planned extensions of NurseOS's GPT integration beyond simple prompt handling.

### 🌟 Capabilities Roadmap

- **Smart Summary**: Auto-summarize patient notes using vector context.
- **Vitals Interpretation**: Detect trends in vitals and flag anomalies.
- **Care Plan Drafting**: Assist nurses in generating care plan templates.

### 🔐 HIPAA Compliance

All prompts:
- Must strip PHI before sending
- Are logged in `gpt_prompts/{promptId}` with metadata only
- Must not include direct user input unless explicitly whitelisted

### 🧰 System Architecture

**Prompt Storage:**
- `gpt_prompts/` collection stores all LLM interactions (de-identified)
- Firestore metadata includes:
  - `uid`, `role`, `timestamp`, `feature`, `actionType`, `model`

**Backend API:**
- Routes all GPT calls via a Firebase HTTPS callable
- Applies prompt templates and OpenAI key
- Logs metadata only (not response body)

**Vector Context (Planned):**
- Embedding pipeline stores vectorized summaries
- Vector queries inform GPT prompts in:
  - note-summarizer
  - trend-analyzer
  - care-plan-generator

**Security Considerations:**
- All LLM calls validated server-side
- Auth claims enforced for access
- Prompt output passed through nurse confirmation UI before committing

---

