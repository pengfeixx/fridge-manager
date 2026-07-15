import 'package:fridge_manager/domain/entities/enums.dart';

class FoodCategory {
  final int? id;
  final String name;
  final String icon;
  final int chilledDefaultDays;
  final int frozenDefaultDays;
  final int roomDefaultDays;

  const FoodCategory({
    this.id,
    required this.name,
    required this.icon,
    required this.chilledDefaultDays,
    required this.frozenDefaultDays,
    required this.roomDefaultDays,
  });

  int defaultDaysFor(Storage storage) => switch (storage) {
        Storage.chilled => chilledDefaultDays,
        Storage.frozen => frozenDefaultDays,
        Storage.room => roomDefaultDays,
      };
}
