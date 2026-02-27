import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart';
import '../models/goal.dart';
import '../models/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection refs
  CollectionReference get _users => _db.collection('users');

  CollectionReference _transactions(String uid) =>
      _users.doc(uid).collection('transactions');

  CollectionReference _goals(String uid) => _users.doc(uid).collection('goals');

  // ── User Profile ──────────────────────────────────────────────────────────
  Future<void> createOrUpdateUser(UserProfile profile) => _users
      .doc(profile.uid)
      .set(profile.toFirestore(), SetOptions(merge: true));

  Future<UserProfile?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  Stream<UserProfile?> userStream(String uid) =>
      _users.doc(uid).snapshots().map((doc) {
        if (!doc.exists) return null;
        return UserProfile.fromFirestore(doc);
      });

  // ── Transactions ──────────────────────────────────────────────────────────
  Stream<List<FinancialTransaction>> transactionsStream(
    String uid, {
    DateTime? from,
    DateTime? to,
    int? limit,
  }) {
    Query query = _transactions(uid).orderBy('date', descending: true);

    if (from != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(from),
      );
    }
    if (to != null) {
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(to));
    }
    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
      (snap) =>
          snap.docs.map((d) => FinancialTransaction.fromFirestore(d)).toList(),
    );
  }

  Future<void> addTransaction(
    String uid,
    FinancialTransaction transaction,
  ) async {
    await _transactions(uid).doc(transaction.id).set(transaction.toFirestore());
  }

  Future<void> updateTransaction(
    String uid,
    FinancialTransaction transaction,
  ) async {
    await _transactions(
      uid,
    ).doc(transaction.id).update(transaction.toFirestore());
  }

  Future<void> deleteTransaction(String uid, String transactionId) async {
    await _transactions(uid).doc(transactionId).delete();
  }

  // ── Goals ─────────────────────────────────────────────────────────────────
  Stream<List<Goal>> goalsStream(String uid) => _goals(uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => Goal.fromFirestore(d)).toList());

  Future<void> addGoal(String uid, Goal goal) async {
    await _goals(uid).doc(goal.id).set(goal.toFirestore());
  }

  Future<void> updateGoal(String uid, Goal goal) async {
    await _goals(uid).doc(goal.id).update(goal.toFirestore());
  }

  Future<void> deleteGoal(String uid, String goalId) async {
    await _goals(uid).doc(goalId).delete();
  }

  // ── Analytics helpers ─────────────────────────────────────────────────────
  Future<List<FinancialTransaction>> getTransactionsForPeriod(
    String uid, {
    required DateTime from,
    required DateTime to,
  }) async {
    final snap =
        await _transactions(uid)
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(to))
            .orderBy('date', descending: true)
            .get();

    return snap.docs.map((d) => FinancialTransaction.fromFirestore(d)).toList();
  }
}
