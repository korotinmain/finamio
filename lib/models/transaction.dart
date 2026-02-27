import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense }

enum TransactionCategory {
  // Expense
  food,
  transport,
  housing,
  health,
  entertainment,
  shopping,
  education,
  utilities,
  travel,
  subscriptions,
  // Income
  salary,
  freelance,
  investment,
  dividend,
  gift,
  other,
}

extension TransactionCategoryX on TransactionCategory {
  String get label {
    switch (this) {
      case TransactionCategory.food:
        return 'Food & Dining';
      case TransactionCategory.transport:
        return 'Transport';
      case TransactionCategory.housing:
        return 'Housing';
      case TransactionCategory.health:
        return 'Health';
      case TransactionCategory.entertainment:
        return 'Entertainment';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.education:
        return 'Education';
      case TransactionCategory.utilities:
        return 'Utilities';
      case TransactionCategory.travel:
        return 'Travel';
      case TransactionCategory.subscriptions:
        return 'Subscriptions';
      case TransactionCategory.salary:
        return 'Salary';
      case TransactionCategory.freelance:
        return 'Freelance';
      case TransactionCategory.investment:
        return 'Investment';
      case TransactionCategory.dividend:
        return 'Dividend';
      case TransactionCategory.gift:
        return 'Gift';
      case TransactionCategory.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case TransactionCategory.food:
        return '🍔';
      case TransactionCategory.transport:
        return '🚗';
      case TransactionCategory.housing:
        return '🏠';
      case TransactionCategory.health:
        return '💊';
      case TransactionCategory.entertainment:
        return '🎬';
      case TransactionCategory.shopping:
        return '🛍️';
      case TransactionCategory.education:
        return '📚';
      case TransactionCategory.utilities:
        return '💡';
      case TransactionCategory.travel:
        return '✈️';
      case TransactionCategory.subscriptions:
        return '📱';
      case TransactionCategory.salary:
        return '💼';
      case TransactionCategory.freelance:
        return '💻';
      case TransactionCategory.investment:
        return '📈';
      case TransactionCategory.dividend:
        return '💰';
      case TransactionCategory.gift:
        return '🎁';
      case TransactionCategory.other:
        return '💫';
    }
  }

  bool get isExpense => [
    TransactionCategory.food,
    TransactionCategory.transport,
    TransactionCategory.housing,
    TransactionCategory.health,
    TransactionCategory.entertainment,
    TransactionCategory.shopping,
    TransactionCategory.education,
    TransactionCategory.utilities,
    TransactionCategory.travel,
    TransactionCategory.subscriptions,
  ].contains(this);
}

class FinancialTransaction {
  final String id;
  final String userId;
  final TransactionType type;
  final TransactionCategory category;
  final double amount;
  final String currency;
  final double amountInBaseCurrency;
  final String? note;
  final DateTime date;
  final DateTime createdAt;

  const FinancialTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.category,
    required this.amount,
    required this.currency,
    required this.amountInBaseCurrency,
    this.note,
    required this.date,
    required this.createdAt,
  });

  factory FinancialTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FinancialTransaction(
      id: doc.id,
      userId: data['userId'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.expense,
      ),
      category: TransactionCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => TransactionCategory.other,
      ),
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] as String? ?? 'USD',
      amountInBaseCurrency:
          (data['amountInBaseCurrency'] as num? ?? data['amount'] as num)
              .toDouble(),
      note: data['note'] as String?,
      date: (data['date'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'type': type.name,
    'category': category.name,
    'amount': amount,
    'currency': currency,
    'amountInBaseCurrency': amountInBaseCurrency,
    'note': note,
    'date': Timestamp.fromDate(date),
    'createdAt': Timestamp.fromDate(createdAt),
  };

  FinancialTransaction copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    TransactionCategory? category,
    double? amount,
    String? currency,
    double? amountInBaseCurrency,
    String? note,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return FinancialTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      amountInBaseCurrency: amountInBaseCurrency ?? this.amountInBaseCurrency,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
