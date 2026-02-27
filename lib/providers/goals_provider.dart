import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

const _uuid = Uuid();

// ── Goals stream ──────────────────────────────────────────────────────────────

final goalsStreamProvider = StreamProvider<List<Goal>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).goalsStream(uid);
});

final activeGoalsProvider = Provider<List<Goal>>((ref) {
  final goals = ref.watch(goalsStreamProvider).valueOrNull ?? [];
  return goals.where((g) => g.status == GoalStatus.active).toList();
});

final completedGoalsProvider = Provider<List<Goal>>((ref) {
  final goals = ref.watch(goalsStreamProvider).valueOrNull ?? [];
  return goals.where((g) => g.status == GoalStatus.completed).toList();
});

// ── Goals notifier ────────────────────────────────────────────────────────────

class GoalsNotifier extends StateNotifier<AsyncValue<void>> {
  GoalsNotifier(this._firestore, this._uid)
    : super(const AsyncValue.data(null));

  final FirestoreService _firestore;
  final String? _uid;

  Future<bool> addGoal({
    required String title,
    required String emoji,
    required double targetAmount,
    required String currency,
    String? description,
    DateTime? targetDate,
  }) async {
    if (_uid == null) return false;
    state = const AsyncValue.loading();
    try {
      final goal = Goal(
        id: _uuid.v4(),
        userId: _uid,
        title: title.trim(),
        description: description?.trim(),
        emoji: emoji,
        targetAmount: targetAmount,
        currentAmount: 0,
        currency: currency,
        targetDate: targetDate,
        status: GoalStatus.active,
        createdAt: DateTime.now(),
      );
      await _firestore.addGoal(_uid, goal);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> addFunds(Goal goal, double amount) async {
    if (_uid == null) return false;
    state = const AsyncValue.loading();
    try {
      final newAmount = (goal.currentAmount + amount).clamp(
        0.0,
        goal.targetAmount,
      );
      final updated = goal.copyWith(
        currentAmount: newAmount,
        status:
            newAmount >= goal.targetAmount ? GoalStatus.completed : goal.status,
      );
      await _firestore.updateGoal(_uid, updated);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteGoal(String goalId) async {
    if (_uid == null) return false;
    state = const AsyncValue.loading();
    try {
      await _firestore.deleteGoal(_uid, goalId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final goalsNotifierProvider =
    StateNotifierProvider<GoalsNotifier, AsyncValue<void>>((ref) {
      return GoalsNotifier(
        ref.watch(firestoreServiceProvider),
        ref.watch(currentUidProvider),
      );
    });
