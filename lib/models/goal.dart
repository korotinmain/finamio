import 'package:cloud_firestore/cloud_firestore.dart';

enum GoalStatus { active, completed, paused }

class Goal {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String emoji;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final DateTime? targetDate;
  final GoalStatus status;
  final DateTime createdAt;

  const Goal({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.emoji,
    required this.targetAmount,
    required this.currentAmount,
    required this.currency,
    this.targetDate,
    required this.status,
    required this.createdAt,
  });

  double get progressPercentage =>
      targetAmount > 0 ? (currentAmount / targetAmount * 100).clamp(0, 100) : 0;

  double get remainingAmount =>
      (targetAmount - currentAmount).clamp(0, double.infinity);

  bool get isCompleted => currentAmount >= targetAmount;

  factory Goal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Goal(
      id: doc.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      description: data['description'] as String?,
      emoji: data['emoji'] as String? ?? '🎯',
      targetAmount: (data['targetAmount'] as num).toDouble(),
      currentAmount: (data['currentAmount'] as num? ?? 0).toDouble(),
      currency: data['currency'] as String? ?? 'USD',
      targetDate:
          data['targetDate'] != null
              ? (data['targetDate'] as Timestamp).toDate()
              : null,
      status: GoalStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => GoalStatus.active,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'title': title,
    'description': description,
    'emoji': emoji,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'currency': currency,
    'targetDate': targetDate != null ? Timestamp.fromDate(targetDate!) : null,
    'status': status.name,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  Goal copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? emoji,
    double? targetAmount,
    double? currentAmount,
    String? currency,
    DateTime? targetDate,
    GoalStatus? status,
    DateTime? createdAt,
  }) => Goal(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    description: description ?? this.description,
    emoji: emoji ?? this.emoji,
    targetAmount: targetAmount ?? this.targetAmount,
    currentAmount: currentAmount ?? this.currentAmount,
    currency: currency ?? this.currency,
    targetDate: targetDate ?? this.targetDate,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
}
