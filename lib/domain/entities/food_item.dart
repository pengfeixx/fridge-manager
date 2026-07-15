import 'package:fridge_manager/domain/entities/enums.dart';

class FoodItem {
  final int? id;
  final String name;
  final int categoryId;
  final double quantity;
  final String unit;
  final Storage storage;
  final DateTime addedDate;
  final int shelfLifeDays;
  final FoodStatus status;
  final String? note;

  const FoodItem({
    this.id,
    required this.name,
    required this.categoryId,
    required this.quantity,
    required this.unit,
    required this.storage,
    required this.addedDate,
    required this.shelfLifeDays,
    this.status = FoodStatus.inStock,
    this.note,
  });

  /// 到期日，实时计算，不落库。
  DateTime get expireDate =>
      addedDate.add(Duration(days: shelfLifeDays));

  FoodItem copyWith({
    int? id,
    String? name,
    int? categoryId,
    double? quantity,
    String? unit,
    Storage? storage,
    DateTime? addedDate,
    int? shelfLifeDays,
    FoodStatus? status,
    String? note,
  }) =>
      FoodItem(
        id: id ?? this.id,
        name: name ?? this.name,
        categoryId: categoryId ?? this.categoryId,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        storage: storage ?? this.storage,
        addedDate: addedDate ?? this.addedDate,
        shelfLifeDays: shelfLifeDays ?? this.shelfLifeDays,
        status: status ?? this.status,
        note: note ?? this.note,
      );

  @override
  String toString() => 'FoodItem($name x$quantity$unit, ${storage.label}, '
      'added=$addedDate, shelfLife=${shelfLifeDays}d)';
}
