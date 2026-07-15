import 'package:fridge_manager/domain/entities/enums.dart';

class RecipeIngredient {
  final int? id;
  final String foodName;
  final double amount;
  final String unit;
  final int? categoryId;

  const RecipeIngredient({
    this.id,
    required this.foodName,
    required this.amount,
    required this.unit,
    this.categoryId,
  });
}

class Recipe {
  final int? id;
  final String title;
  final List<RecipeIngredient> ingredients;
  final List<String> steps;
  final List<String> tags;
  final RecipeSource source;

  const Recipe({
    this.id,
    required this.title,
    this.ingredients = const [],
    this.steps = const [],
    this.tags = const [],
    this.source = RecipeSource.local,
  });
}
