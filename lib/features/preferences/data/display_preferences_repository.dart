import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/display_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DisplayPreferencesRepository {
  final FirebaseFirestore firestore;

  DisplayPreferencesRepository({required this.firestore});

  Future<DisplayPreferences> fetch(String uid) async {
    final doc =
        await firestore.doc('users/$uid/settings/displayPreferences').get();
    if (!doc.exists) return DisplayPreferences.defaults();
    return DisplayPreferences.fromJson(doc.data() ?? {});
  }

  Future<void> save(String uid, DisplayPreferences prefs) async {
    await firestore
        .doc('users/$uid/settings/displayPreferences')
        .set(prefs.toJson());
  }
}

final displayPreferencesRepositoryProvider = Provider((ref) {
  return DisplayPreferencesRepository(firestore: FirebaseFirestore.instance);
});
