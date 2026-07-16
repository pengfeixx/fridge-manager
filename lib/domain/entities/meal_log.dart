import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';

class MealEntry {
  final int? id;
  final NutritionCategory category;
  final double amountGram;
  final String? description;

  const MealEntry({
    this.id,
    required this.category,
    required this.amountGram,
    this.description,
  });

  MealEntry copyWith({
    int? id,
    NutritionCategory? category,
    double? amountGram,
    String? description,
  }) =>
      MealEntry(
        id: id ?? this.id,
        category: category ?? this.category,
        amountGram: amountGram ?? this.amountGram,
        description: description ?? this.description,
      );
}

class MealLog {
  final int? id;
  final DateTime date;
  final MealType mealType;
  final List<MealEntry> entries;

  const MealLog({
    this.id,
    required this.date,
    required this.mealType,
    this.entries = const [],
  });
}
