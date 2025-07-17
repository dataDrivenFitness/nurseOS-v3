// Quick script to fix user's activeAgencyId
// Run with: dart fix_user_agency.dart

import 'dart:io';

void main() {
  print('This script needs to be run as a Flutter command with Firebase access.');
  print('Copy the following code into your app and run it once:');
  print('');
  print('// Add this method to any screen temporarily:');
  print('void _fixUserAgency() async {');
  print('  final user = FirebaseAuth.instance.currentUser;');
  print('  if (user != null) {');
  print('    await FirebaseFirestore.instance');
  print('        .collection("users")');
  print('        .doc(user.uid)');
  print('        .update({"activeAgencyId": "rising-phoenix"});');
  print('    print("✅ Updated user activeAgencyId to rising-phoenix");');
  print('  }');
  print('}');
  print('');
  print('Then call _fixUserAgency() from a button press.');
}