# HIPAA Readiness Checklist – NurseOS v2

> This checklist ensures compliance with the HIPAA Security Rule for NurseOS v2 architecture, processes, and vendor integrations.

---

## ✅ Administrative Safeguards

- [x] **Risk Assessment**
  - Ongoing threat modeling and mitigation strategy
  - Documented annually and post-incident

- [x] **Security Policies**
  - Access, data usage, and incident response policies maintained
  - Signed acknowledgment from all personnel

- [x] **Workforce Training**
  - Annual HIPAA training for all team members
  - Training logs stored securely

- [x] **Access Control Policies**
  - Role-based access (RBAC) with least-privilege enforcement
  - Firebase custom claims used for runtime auth

- [x] **Audit Controls**
  - Access logs retained for all PHI touchpoints
  - Custom logging integrated with Firebase Audit

---

## ✅ Physical Safeguards

- [x] **Device Security**
  - MDM enforced on all production-access devices
  - Remote wipe enabled for compromised devices

- [x] **Data Disposal**
  - Secure erase procedures for decommissioned hardware
  - Verified by security leads

- [x] **Access Restrictions**
  - Workspace access secured via VPN or zero-trust
  - No PHI access over unsecured public networks

---

## ✅ Technical Safeguards

- [x] **Data Encryption**
  - AES-256 at rest (Firebase Firestore and Cloud Storage)
  - TLS 1.3 in transit (via HTTPS, gRPC)

- [x] **Access Controls**
  - Firebase Authentication with role enforcement
  - Re-authentication required for sensitive actions

- [x] **Audit Logs**
  - Retained for minimum 6 years
  - Monitored via automated alerts and periodic review

- [x] **Automatic Logoff**
  - Session expiration enforced after inactivity
  - Secure re-auth prompt upon session renewal

---

## ✅ Organizational Requirements

- [x] **Business Associate Agreements (BAAs)**
  - Firebase (Google Cloud BAA signed)
  - OpenAI (API usage limited to de-identified requests)

- [x] **Subcontractor Compliance**
  - All third-party integrations reviewed for HIPAA alignment
  - Compliance certifications documented and stored

---

## ✅ Policies & Procedures

- [x] **Incident Response Plan**
  - Breach notification protocol with 72-hour SLA
  - Triage, root cause, and corrective action steps logged

- [x] **Contingency Plan**
  - Automated daily backups
  - Restore procedures tested quarterly

- [x] **Documentation Retention**
  - All policy versions and change logs archived
  - Minimum 6-year document retention policy

---

