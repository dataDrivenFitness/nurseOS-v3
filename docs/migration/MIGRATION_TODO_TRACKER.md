# 🚨 MIGRATION TODO TRACKER - NurseOS Multi-Agency

> **CRITICAL**: These changes must be completed during migration or we'll have data consistency issues

---

## 🔧 **Required Model Changes After Migration**

### **1. ShiftModel - Make agencyId Required**
**File:** `lib/features/schedule/shift_pool/models/shift_model.dart`

**Current (Temporary):**
```dart
String? agencyId,  // ← TEMPORARY - nullable for existing data
```

**Must Change To:**
```dart
required String agencyId,  // ← REQUIRED after migration
```

**Why:** All shifts will have agencyId after migration, so it should be required

### **2. ScheduledShiftModel - Make agencyId Required**
**File:** `lib/features/schedule/models/scheduled_shift_model.dart`

**Current (Temporary):**
```dart
String? agencyId,  // ← TEMPORARY - nullable for existing data
```

**Must Change To:**
```dart
required String agencyId,  // ← REQUIRED after migration
```

**Why:** All scheduled shifts will have agencyId after migration, so it should be required

---

## 📋 **Migration Script Requirements**

### **Data Migration Steps:**
1. **Read all existing shifts** from `/shifts/` and `/scheduledShifts/` collections
2. **Assign default agency** (`default_agency`) to each shift
3. **Copy to agency collections** (`/agencies/default_agency/shifts/` and `/agencies/default_agency/scheduledShifts/`)
4. **Validate all shifts have agencyId**
5. **Update models** to make agencyId required
6. **Test thoroughly** before deploying

### **Validation Checks:**
- [ ] All shifts have valid agencyId
- [ ] No null agencyId values in database
- [ ] Agency-scoped queries work correctly
- [ ] Legacy collection can be archived

---

## 🎯 **Sprint Checklist Integration**

**Add to Sprint 1 completion criteria:**
- [ ] Migration script handles ShiftModel agencyId assignment
- [ ] Migration script handles ScheduledShiftModel agencyId assignment  
- [ ] Post-migration: Update models to make agencyId required
- [ ] Post-migration: Run full test suite
- [ ] Post-migration: Verify no null agencyId in production

---

## 🚨 **Danger Zones**

### **If We Forget:**
- ❌ **Runtime errors** when users switch agencies
- ❌ **Data isolation failures** - users see wrong agency's shifts
- ❌ **Security issues** - cross-agency data leakage
- ❌ **Broken queries** - agency-scoped filters won't work

### **Prevention:**
- ✅ **This document** stays updated with model changes
- ✅ **Migration script** includes model requirement updates
- ✅ **Testing** includes agencyId validation
- ✅ **Code review** checks for nullable → required conversions

---

## 📅 **Timeline**

**During Development (Now):**
- Models have nullable agencyId
- App works with existing data
- Continue building features

**During Migration (Sprint 1-2):**
- Migration script assigns agencyId to all records
- Validate data integrity

**After Migration (Sprint 2-3):**
- **MUST UPDATE**: Change agencyId from nullable to required
- **MUST TEST**: Verify all agency-scoped functionality
- **MUST VALIDATE**: No null agencyId in any collection

---

## 🔍 **Files to Update Post-Migration**

1. `lib/features/schedule/shift_pool/models/shift_model.dart`
2. `lib/features/schedule/models/scheduled_shift_model.dart` 
3. Any other models we add agencyId to during development
4. Run `dart run build_runner build` after changes
5. Update integration tests to expect required agencyId

---

**🎯 Bottom Line:** This tracker ensures we don't ship with nullable agencyId fields that should be required after migration.