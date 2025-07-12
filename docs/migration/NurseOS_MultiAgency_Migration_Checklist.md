# 🛣️ **NurseOS Multi-Agency Migration Roadmap – Enhanced Version**

> **Version:** 2025-07-10 (Enhanced)  
> **Scope:** Auth • Patient • User Profile • Schedule • Work History • Preferences • Agency  
> **Goal:** Production-ready multi-agency support for the shipped slices, with basic role-gated Admin panel.

---

## 🗓️ Milestone Timeline

| Sprint (Mon–Fri) | Theme | High-Level Deliverables |
|------------------|-------|-------------------------|
| **Sprint 0**<br>Jul 10 – Jul 11 | **Backlog & Setup** | Groom tasks, create GitHub issues, stub migration tests |
| **Sprint 1**<br>Jul 14 – Jul 18 | **Model & Repo Propagation** | `agencyId` on **Shift** & **Visit** models; repo refactors; migration script |
| **Sprint 2**<br>Jul 21 – Jul 25 | **Router + Guard Polish** | Global guard, agency chip in Profile, refresh hook wiring |
| **Sprint 3**<br>Jul 28 – Aug 01 | **Security & CI** | Firestore rule expansion, emulator rule tests in CI |
| **Sprint 4**<br>Aug 04 – Aug 08 | **Role-Gated Admin & UX Finishing** | Admin dashboard relocation + guard, doc updates, staging dry-run |
| **Release Cut**<br>Aug 11 | **Week-3 Definition of Done** review & prod deploy |

---

## ✅ Enhanced Detailed Checklist

### 1 — Data Model & Repository **[ENHANCED]**

- [ ] **AgencyModel** & **AgencyRoleModel** → create if missing (freezed + json_serializable)
- [ ] **UserModel** → add `activeAgencyId` & `agencyRoles` fields if missing
- [ ] **ShiftModel** → add `agencyId`, update `.withConverter()`  
- [ ] **VisitModel** → add `agencyId`, update `.withConverter()`  
- [ ] **WorkSession** → add `agencyId` to work history tracking
- [ ] **FirebaseShiftRepository** refactored to `agencies/{agencyId}/shifts` path  
- [ ] **FirebaseVisitRepository** refactored similarly  
- [ ] **FirebaseWorkHistoryRepository** → ensure work sessions stay user-scoped (not agency-scoped)
- [ ] Provide `shiftRepositoryProvider(agencyId)` and `visitRepositoryProvider(agencyId)` families  
- [ ] **Migration script**: copy legacy `/shifts/` & `/visits/` → `agencies/{default}/…`  
  - ↳ [ ] **ENHANCED**: Add validation step to check data integrity
  - ↳ [ ] **ENHANCED**: Add rollback capability for production safety
  - ↳ [ ] smoke test in emulator with realistic data volumes

---

### 2 — Routing & Context Guards **[ENHANCED]**

- [ ] **AgencyContextNotifier** → implement with agency switching logic
- [ ] **AgencySelectionScreen** → create with UX for multiple agencies
- [ ] On post-login, **if** `activeAgencyId == null` → force `AgencySelectionScreen`  
- [ ] **AuthRefreshNotifier** listens for agency changes to re-eval routes  
- [ ] **Profile screen**: add tappable *AgencyChip* (shows current agency, opens switcher)  
- [ ] **ENHANCED**: Add "No agencies" state handling for users without assignments
- [ ] **ENHANCED**: Add agency switching confirmation dialog for data safety
- [ ] Widget test: chip updates on `agencyContextNotifierProvider` change  

---

### 3 — Security Rules & Continuous Integration **[ENHANCED]**

- [ ] Extend Firestore rules for `agencies/{agencyId}/shifts`, `visits`, `admin` collections  
- [ ] **ENHANCED**: Add agency-specific audit logging rules
- [ ] **ENHANCED**: Add cross-agency data isolation validation
- [ ] Write emulator rule tests:  
  - [ ] Nurse from Agency A cannot read Agency B shift  
  - [ ] Non-admin hits `/admin/` → **PERMISSION_DENIED**  
  - [ ] **ENHANCED**: User with multiple agencies can switch contexts
  - [ ] **ENHANCED**: Work history remains user-scoped across agencies
- [ ] Add `firebase emulators:exec` step to GitHub CI to gate merges  
- [ ] **ENHANCED**: Add performance regression tests for agency-scoped queries

---

### 4 — Role-Gated Admin Panel **[ENHANCED]**

- [ ] Move screen → `lib/features/admin/`  
- [ ] Create `RoleGuard` (`role ∈ {admin, supervisor}` within `agencyRoles[activeAgencyId]`)  
- [ ] **ENHANCED**: Add `AgencyAdminScreen` for agency-specific management
- [ ] **ENHANCED**: Add user assignment/removal functionality for admins
- [ ] Update navigation to surface link only for authorised roles  
- [ ] Rule: allow `/agencies/{id}/admin/**` only for authorised roles  
- [ ] **ENHANCED**: Add audit trail for admin actions

---

### 5 — Testing Matrix **[ENHANCED]**

| Layer | Scenario | Tool | **Enhanced Coverage** |
|-------|----------|------|----------------------|
| **Unit** | `FirebaseShiftRepository` returns only current-agency docs | `FakeFirebaseFirestore` | ✅ |
| **Integration** | `switchAgency()` triggers provider refresh & UI rebuild | `flutter_test` + mock auth | ✅ |
| **Security** | Cross-agency read → DENIED | Emulator | **+ Performance testing** |
| **Migration** | Legacy `/visits/{id}` migrated with `agencyId` populated | CLI test harness | **+ Rollback testing** |
| **Widget** | AgencyChip updates live | Golden + pump frame | **+ Loading states** |
| **Golden** | Shift list with FAB & text scaling | Golden tests | **+ Agency selection screen** |
| **E2E** | **NEW**: Complete agency switching flow | Integration tests | **Multi-agency user journey** |

---

### 6 — Documentation & Compliance **[ENHANCED]**

- [ ] **NurseOS_v2_ARCHITECTURE.md** – add note: "Schedule & WorkHistory now scoped by agencyId"  
- [ ] **Firebase_Integration_Strategy.md** – insert new collection paths  
- [ ] **HIPAA_Readiness_Checklist.md** – confirm no PHI added to Shift/Visit docs  
- [ ] **NurseOS_Refactor_Roadmap_v2.md** – mark phase tasks complete  
- [ ] **Feature_Dev_Guide_v2-2.md** – update model list & repository requirements  
- [ ] **ENHANCED**: Create `Multi_Agency_User_Guide.md` for end-user training
- [ ] **ENHANCED**: Update `vulnerability_test_guide.md` with agency isolation tests

---

### 7 — Production Safety **[NEW SECTION]**

- [ ] **Staging Environment**: Full migration dry-run with production data clone
- [ ] **Feature Flags**: Implement agency feature toggle for gradual rollout
- [ ] **Monitoring**: Set up alerts for agency switching errors and performance
- [ ] **Rollback Plan**: Document and test emergency rollback procedures
- [ ] **User Communication**: Prepare announcement and training materials

---

## 📈 Sprint Dashboard Template (Enhanced)

```markdown
### Sprint 1 — Model & Repo Propagation (Jul 14 – Jul 18)

| Issue | Task | Owner | Status | Notes |
|-------|------|-------|--------|----- |
| #123  | Add `agencyId` to ShiftModel | @devA | ⬜ | Include validation |
| #124  | Add `agencyId` to VisitModel | @devA | ⬜ | Include validation |
| #125  | FirebaseShiftRepository refactor | @devB | ⬜ | Test with emulator |
| #126  | FirebaseVisitRepository refactor | @devB | ⬜ | Test with emulator |
| #127  | Migration script & smoke test | @devC | ⬜ | Include rollback |
| #128  | **NEW**: AgencyModel creation | @devA | ⬜ | Freezed + JSON |
| #129  | **NEW**: UserModel agency fields | @devA | ⬜ | Backward compatible |
```

---

## 🎯 **Enhanced Week-3 Definition of Done**

### **Core Functionality**
* All **Shift** & **Visit** data scoped by `agencyId` and migrated.  
* **WorkSession** data remains user-scoped (cross-agency).
* No screen reachable without an active agency context.  
* Admin dashboard hidden unless role permits.  

### **Quality Assurance**
* CI fails on security-rule regressions.  
* **ENHANCED**: Performance benchmarks maintained (query times < 500ms).
* **ENHANCED**: Migration rollback tested and documented.

### **User Experience**
* Profile header shows current agency chip.  
* **ENHANCED**: Agency switching works smoothly with loading states.
* **ENHANCED**: "No agencies" state handled gracefully.

### **Production Readiness**
* **ENHANCED**: Feature flag implemented for gradual rollout.
* **ENHANCED**: Monitoring and alerting configured.
* **ENHANCED**: User training materials prepared.

### **Documentation**
* Docs & checklists updated.  
* **ENHANCED**: Architecture decisions documented.
* **ENHANCED**: Security isolation validated and documented.

---

## 🔄 **Migration Safety Enhancements**

### **Validation Pipeline**
1. **Pre-migration**: Data integrity check
2. **During migration**: Progress monitoring with rollback triggers
3. **Post-migration**: Validation of all data relationships
4. **User acceptance**: Gradual rollout with feedback collection

### **Rollback Triggers**
- Data loss detected (> 0.1%)
- Performance degradation (> 50% slower queries)
- User authentication failures (> 5%)
- Agency context failures (> 2%)

---

## 💡 **Key Architectural Decisions**

### **What Stays User-Scoped**
- **WorkSession** history (nurses work across agencies)
- **Gamification** data (XP, badges, levels)
- **User preferences** and settings
- **Authentication** and profile data

### **What Becomes Agency-Scoped**
- **Patient** data (complete isolation)
- **Shift** schedules (agency-specific)
- **Visit** records (agency-specific)
- **Admin** functions (agency-specific)
- **Task** assignments (agency-specific)

### **What Remains Global**
- **Agency** metadata (readable by members)
- **App configuration** (global settings)
- **Audit logs** (security and compliance)

---

This enhanced roadmap maintains your excellent strategic approach while adding production safety measures and comprehensive testing that aligns with your existing NurseOS v2 architecture patterns.