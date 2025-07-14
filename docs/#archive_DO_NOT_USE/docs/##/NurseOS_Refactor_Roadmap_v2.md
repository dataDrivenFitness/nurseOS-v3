# 🗺️ NurseOS v2 Refactor Roadmap

This roadmap guides the test-driven rebuild of NurseOS v2 with modular architecture, HIPAA-safe practices, and **shift-centric patient relationships**.

---

## ✅ Phase 0 – Safety Net

- [x] Tag current v1 commit
- [x] Export full backup archive
- [x] Snapshot user schema + Firestore structure

---

## 🧱 Phase 1 – Scaffold

- [x] Create `v2` branch
- [x] Establish folder structure (`core/`, `features/`, `shared/`)
- [x] Add `.env` + firebase config stubs

---

## 🧪 Phase 2 – Tooling

- [x] Lints (`very_good_analysis`)
- [x] CI actions: analyze, test, format
- [x] Pre-commit hook
- [x] Type-scaling golden test scaffolds

---

## 🚀 Phase 3 – Core System Port

- [x] Migrate user/auth model
- [x] Set up Riverpod + FirebaseAuth integration
- [x] ThemeController + dark mode toggle
- [x] DisplayPreferences model + Firestore sync
- [x] FontScaleController with app-wide MediaQuery override

---

## 🏥 **Phase 4 – Shift-Centric Foundation (NEW)**

### **4.1 Data Model Extensions** ✅
- [x] Extend UserModel with independent nurse fields (`isIndependentNurse`, `businessName`)
- [x] Enhance ScheduledShiftModel with agency scoping (`agencyId`, `isUserCreated`, `createdBy`)
- [x] Create agency-scoped Firestore converters for shift isolation
- [x] Add extension methods for shift ownership logic
- [x] Build feature flag system for navigation switching

### **4.2 Navigation Architecture** 🔄
- [x] Update AppShell with feature flag routing
- [x] Create Available Shifts Screen (agency + independent shift discovery)
- [ ] Build My Shift Screen with sub-tabs ([Patients] [Tasks])
- [ ] Implement shift creation wizard (follows patient creation patterns)
- [ ] Add patient assignment workflows with agency boundary enforcement

### **4.3 Shift-Centric Patient Access** 📋
- [ ] Update patient queries to be shift-based only
- [ ] Remove `assignedNurses` field from Patient model
- [ ] Implement duty status enforcement (off-duty = no patient access)
- [ ] Add shift-based patient list filtering
- [ ] Create patient assignment validation (agency boundaries)

---

## 🔁 Phase 5 – Enhanced Navigation & Workflows

### **5.1 Shift Management**
- [ ] Independent nurse shift creation flow
- [ ] Agency shift request and approval workflow
- [ ] Shift editing and cancellation (ownership-based permissions)
- [ ] Multi-agency daily schedule view
- [ ] Shift conflict detection and resolution

### **5.2 Patient Management Evolution**
- [ ] Patient list screen (shift-filtered)
- [ ] Patient detail screen with shift context
- [ ] Add patient screen with shift assignment step
- [ ] Patient-to-shift assignment workflows
- [ ] Cross-agency patient access prevention

### **5.3 Task System Integration**
- [ ] Shift-scoped task management
- [ ] Task creation within shift context
- [ ] XP attribution tied to shift work
- [ ] Task completion tracking per shift
- [ ] Shift-based task reporting

---

## 🎮 Phase 6 – Gamification & Task System

### **6.1 Shift-Integrated Gamification**
- [ ] Tasks + XP gamification within shift context
- [ ] Dashboard: pending tasks + levels (shift-aware)
- [ ] Shift timing, session badge triggers
- [ ] XP rewards for shift completion and quality metrics
- [ ] Independent nurse vs agency nurse leaderboards

### **6.2 Advanced Task Workflows**
- [ ] Note-taking with progressive disclosure
- [ ] Vitals entry screen (shift context)
- [ ] Head-to-toe assessments per shift
- [ ] Care plan updates within shift workflow
- [ ] Medication management per shift

---

## 🏢 **Phase 7 – Agency & Independent Features**

### **7.1 Agency Admin Tools**
- [ ] Agency shift creation and management
- [ ] Nurse assignment to agency shifts
- [ ] Agency-scoped reporting and analytics
- [ ] Shift approval and oversight workflows
- [ ] Agency nurse performance tracking

### **7.2 Independent Nurse Business Tools**
- [ ] Independent shift scheduling and patient management
- [ ] Business reporting and invoicing support
- [ ] Independent nurse patient roster management
- [ ] Rate setting and service area configuration
- [ ] Independent practice analytics

### **7.3 Multi-Agency Support**
- [ ] Nurse agency affiliation management
- [ ] Context switching between agencies and independent work
- [ ] Multi-agency conflict detection
- [ ] Agency isolation and data privacy enforcement
- [ ] Cross-agency compliance reporting

---

## 📊 **Phase 8 – Advanced Features**

### **8.1 EVV & Compliance**
- [ ] Electronic Visit Verification with GPS logging
- [ ] HIPAA-safe visit notes linked to shift and patient
- [ ] Shift-based audit trail and compliance reporting
- [ ] Agency-specific compliance requirements
- [ ] Independent nurse compliance tracking

### **8.2 Schedule Optimization**
- [ ] Shift scheduling with drag-and-drop interface
- [ ] Travel time optimization for home care shifts
- [ ] Multi-patient shift routing and scheduling
- [ ] Availability matching and shift suggestions
- [ ] Calendar integration and scheduling conflict resolution

---

## 🧼 Phase 9 – Data Migration & Cleanup

### **9.1 Legacy Data Migration**
- [ ] Migrate existing patient assignments to shift-based model
- [ ] Update existing shifts with agency assignments
- [ ] Remove deprecated `assignedNurses` fields from Patient model
- [ ] Validate data integrity across all collections
- [ ] Archive v1 schema and migration scripts

### **9.2 System Optimization**
- [ ] Performance optimization for shift-centric queries
- [ ] Firestore index optimization for agency-scoped collections
- [ ] Cache invalidation strategy for shift-based data
- [ ] Memory optimization for multi-shift daily views
- [ ] Background sync for offline shift management

---

## 🚀 Phase 10 – Production & Polish

### **10.1 Feature Flag Migration**
- [ ] Gradual rollout of new navigation to beta users
- [ ] Performance monitoring and user feedback collection
- [ ] A/B testing of shift-centric vs legacy workflows
- [ ] Full migration from old to new navigation system
- [ ] Remove legacy navigation and feature flags

### **10.2 Final Release Preparation**
- [ ] Comprehensive testing of shift-centric workflows
- [ ] Agency onboarding and training materials
- [ ] Independent nurse setup and configuration guides
- [ ] Performance benchmarking and optimization
- [ ] Final QA + release checklist

---

## 🤖 Phase 11 – LLM Assistant + AI Copilot (Enhanced)

### **11.1 Shift-Aware AI Features**
- [ ] Shift summary generation with patient context
- [ ] AI-powered task prioritization within shifts
- [ ] Intelligent shift scheduling recommendations
- [ ] Patient care plan suggestions based on shift patterns
- [ ] Predictive shift conflict detection

### **11.2 Advanced AI Integration**
- [ ] Vector database for patient context retrieval (shift-scoped)
- [ ] GPT integration for shift note summarization
- [ ] AI-powered care plan drafting within shift workflow
- [ ] Intelligent patient assignment recommendations
- [ ] Agency-specific AI compliance and audit features

---

## 🎯 **Critical Success Metrics**

### **Architecture Compliance**
- ✅ **100% shift-centric patient access** (no direct assignments)
- ✅ **Complete agency data isolation** (no cross-agency access)
- ✅ **HIPAA-compliant audit trails** for all patient interactions
- ✅ **Independent nurse support** with business tool integration

### **User Experience**
- ✅ **Intuitive shift creation** for independent nurses
- ✅ **Seamless agency context switching** for dual-mode nurses
- ✅ **Clear shift ownership** and permission indicators
- ✅ **Efficient multi-shift daily scheduling** workflows

### **Business Impact**
- ✅ **Independent nurse adoption** and revenue growth
- ✅ **Agency satisfaction** with data control and isolation
- ✅ **Reduced support tickets** from clearer user workflows
- ✅ **Improved compliance** with automated shift-based access control

---

## 📋 **Phase Dependencies**

- **Phase 4** must complete before **Phase 5** (foundation before features)
- **Phase 4.3** blocks **Phase 5.2** (shift-centric access before patient workflows)
- **Phase 6** depends on **Phase 5.3** (task system needs shift context)
- **Phase 9** requires **Phase 7** completion (migration after all features built)

---

# ✅ Let's build the future of nursing technology.

## 📎 **Updated Linked Documents**

- [x] **NurseOS_v2_ARCHITECTURE.md** - Updated with shift-centric architecture
- [ ] **Shift_Centric_Architecture_Reference.md** - New comprehensive guide
- [ ] **NurseOS_Feature_Dev_Guide_v2-2.md** - Add shift development patterns
- [ ] **Independent_Nurse_User_Guide.md** - New user documentation