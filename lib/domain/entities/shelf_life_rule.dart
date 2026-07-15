import 'package:fridge_manager/domain/entities/enums.dart';

class ShelfLifeRule {
  final int? id;
  final String foodName;
  final List<String> aliases;
  final Storage storage;
  final int defaultDays;

  const ShelfLifeRule({
    this.id,
    required this.foodName,
    this.aliases = const [],
    required this.storage,
    required this.defaultDays,
  });
}
