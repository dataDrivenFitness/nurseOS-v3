import 'package:cloud_firestore/cloud_firestore.dart';
import 'abstract_xp_repository.dart';

class FirebaseXpRepository implements AbstractXpRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  @override
  Future<int> getXp(String userId) async {
    final doc = await _users.doc(userId).get();
    final data = doc.data();
    if (data == null || !data.containsKey('xp')) return 0;
    return data['xp'] as int;
  }

  @override
  Future<void> incrementXp(String userId, {int amount = 1}) async {
    final userRef = _users.doc(userId);
    await _db.runTransaction((txn) async {
      final snapshot = await txn.get(userRef);
      final current = (snapshot.data()?['xp'] ?? 0) as int;
      txn.update(userRef, {'xp': current + amount});
    });
  }
}
