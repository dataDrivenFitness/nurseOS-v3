# 📄 SUBSCRIPTION_AND_REFERRAL_PLAN.md

This document outlines how to implement subscription tier enforcement, referral logic, and related Firestore/UserModel updates in NurseOS.

---

## ✅ Overview

We are preparing the app to:

1. Enforce feature access based on a user's subscription tier (`free`, `pro`, `team`)
2. Introduce shareable referral codes tied to Firestore `uid`s
3. Use referrals to fuel organic growth and future reward systems
4. Defer Stripe integration until post-MVP, while fully scaffolding access control

---

## 🔧 USER MODEL CHANGES

Extend your `UserModel`:

```dart
class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String subscriptionTier; // 'free', 'pro', 'team', etc.
  final String referralCode;     // Public-facing invite code (e.g., ref_ab12xy)
  final String? referralId;      // UID of the user who referred them
  final int referredCount;       // For rewards/tracking

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.subscriptionTier,
    required this.referralCode,
    this.referralId,
    this.referredCount = 0,
  });
}
```

---

## 🧱 FIRESTORE STRUCTURE

Each `users/{uid}` document should include:

```json
{
  "subscriptionTier": "free",      // 'free', 'pro', or 'team'
  "referralCode": "ref_ab12xy",    // Shareable invite code
  "referralId": "UID1234...",      // UID of the user who referred them
  "referredCount": 2,              // How many users this person referred
  "stripeCustomerId": null,        // (for later)
  "subscriptionId": null,          // (for later)
  "trialEndsAt": null              // (for later)
}
```

---

## 🧠 SUBSCRIPTION GATING LOGIC

Create helpers:

```dart
bool isPro(UserModel user) => user.subscriptionTier == 'pro';

bool isTeam(UserModel user) =>
    user.subscriptionTier == 'team' || user.subscriptionTier == 'enterprise';
```

Use these to guard features:

```dart
if (isPro(user)) {
  return AIHandoffWidget();
} else {
  return UpgradePrompt();
}
```

---

## 🧪 REFERRAL CODE GENERATION (ON FIRST SIGNUP)

```dart
String generateReferralCode() {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rand = Random.secure();
  final code = List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  return 'ref_$code';
}
```

Write it to Firestore:

```dart
await FirebaseFirestore.instance
  .collection('users')
  .doc(uid)
  .set({
    'referralCode': generateReferralCode(),
  }, SetOptions(merge: true));
```

---

## 🔍 REFERRAL CODE REDEMPTION (SIGN-UP FLOW)

1. On signup form, collect `referralCodeInput`
2. Query Firestore:

```dart
final match = await FirebaseFirestore.instance
  .collection('users')
  .where('referralCode', isEqualTo: referralCodeInput)
  .limit(1)
  .get();

if (match.docs.isNotEmpty) {
  final referrerUid = match.docs.first.id;

  await FirebaseFirestore.instance
    .collection('users')
    .doc(currentUser.uid)
    .set({
      'referralId': referrerUid,
    }, SetOptions(merge: true));

  await FirebaseFirestore.instance
    .collection('users')
    .doc(referrerUid)
    .update({
      'referredCount': FieldValue.increment(1),
    });
}
```

---

## 📱 REFERRAL BUTTON (Profile Screen)

Create a `ReferralButton` widget:

```dart
ElevatedButton.icon(
  icon: const Icon(Icons.send),
  label: const Text('Refer a Nurse'),
  onPressed: () => _shareReferral(user.referralCode),
)

void _shareReferral(String code) async {
  final message = Uri.encodeComponent(
    'Hey! Try NurseOS – use my referral code $code to get started:\n\n[InsertLinkHere]'
  );
  final smsUrl = Uri.parse('sms:?body=$message');

  if (await canLaunchUrl(smsUrl)) {
    await launchUrl(smsUrl);
  }
}
```

---

## 🔐 FIRESTORE SECURITY RULES (FOR SUBSCRIPTION-GATED DATA)

```js
match /pro_features/{docId} {
  allow read, write: if
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.subscriptionTier == "pro";
}
```

---

## 🧱 FUTURE TASKS (POST-MVP)

| Feature                      | Triggered By                      |
|------------------------------|-----------------------------------|
| Stripe checkout integration  | Upgrade flow                      |
| Webhook to update Firestore  | Stripe `checkout.session.complete` |
| Auto reward for referrals    | Stripe upgrade webhook + logic    |
| Dynamic links in referral    | Firebase Dynamic Links            |
| Admin referral dashboard     | Later admin panel                 |

---

## 🧭 SUMMARY

You can roll out this system incrementally:

- ✅ Now: generate + store referralCode, gate features by tier, mock UI
- 🚧 Later: Stripe payment + webhook logic
- 🎯 Result: scalable, secure, rewardable referral + subscription system

---