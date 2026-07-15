// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FoodItemsTable extends FoodItems
    with TableInfo<$FoodItemsTable, FoodItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<Storage, String> storage =
      GeneratedColumn<String>('storage', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Storage>($FoodItemsTable.$converterstorage);
  static const VerificationMeta _addedDateMeta =
      const VerificationMeta('addedDate');
  @override
  late final GeneratedColumn<DateTime> addedDate = GeneratedColumn<DateTime>(
      'added_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _shelfLifeDaysMeta =
      const VerificationMeta('shelfLifeDays');
  @override
  late final GeneratedColumn<int> shelfLifeDays = GeneratedColumn<int>(
      'shelf_life_days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('inStock'));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        categoryId,
        quantity,
        unit,
        storage,
        addedDate,
        shelfLifeDays,
        status,
        note
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_items';
  @override
  VerificationContext validateIntegrity(Insertable<FoodItemData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('added_date')) {
      context.handle(_addedDateMeta,
          addedDate.isAcceptableOrUnknown(data['added_date']!, _addedDateMeta));
    } else if (isInserting) {
      context.missing(_addedDateMeta);
    }
    if (data.containsKey('shelf_life_days')) {
      context.handle(
          _shelfLifeDaysMeta,
          shelfLifeDays.isAcceptableOrUnknown(
              data['shelf_life_days']!, _shelfLifeDaysMeta));
    } else if (isInserting) {
      context.missing(_shelfLifeDaysMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodItemData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      storage: $FoodItemsTable.$converterstorage.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage'])!),
      addedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_date'])!,
      shelfLifeDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}shelf_life_days'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $FoodItemsTable createAlias(String alias) {
    return $FoodItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<Storage, String> $converterstorage =
      const StorageConverter();
}

class FoodItemData extends DataClass implements Insertable<FoodItemData> {
  final int id;
  final String name;
  final int categoryId;
  final double quantity;
  final String unit;
  final Storage storage;
  final DateTime addedDate;
  final int shelfLifeDays;
  final String status;
  final String? note;
  const FoodItemData(
      {required this.id,
      required this.name,
      required this.categoryId,
      required this.quantity,
      required this.unit,
      required this.storage,
      required this.addedDate,
      required this.shelfLifeDays,
      required this.status,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['category_id'] = Variable<int>(categoryId);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    {
      map['storage'] =
          Variable<String>($FoodItemsTable.$converterstorage.toSql(storage));
    }
    map['added_date'] = Variable<DateTime>(addedDate);
    map['shelf_life_days'] = Variable<int>(shelfLifeDays);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  FoodItemsCompanion toCompanion(bool nullToAbsent) {
    return FoodItemsCompanion(
      id: Value(id),
      name: Value(name),
      categoryId: Value(categoryId),
      quantity: Value(quantity),
      unit: Value(unit),
      storage: Value(storage),
      addedDate: Value(addedDate),
      shelfLifeDays: Value(shelfLifeDays),
      status: Value(status),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory FoodItemData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodItemData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      storage: serializer.fromJson<Storage>(json['storage']),
      addedDate: serializer.fromJson<DateTime>(json['addedDate']),
      shelfLifeDays: serializer.fromJson<int>(json['shelfLifeDays']),
      status: serializer.fromJson<String>(json['status']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'categoryId': serializer.toJson<int>(categoryId),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'storage': serializer.toJson<Storage>(storage),
      'addedDate': serializer.toJson<DateTime>(addedDate),
      'shelfLifeDays': serializer.toJson<int>(shelfLifeDays),
      'status': serializer.toJson<String>(status),
      'note': serializer.toJson<String?>(note),
    };
  }

  FoodItemData copyWith(
          {int? id,
          String? name,
          int? categoryId,
          double? quantity,
          String? unit,
          Storage? storage,
          DateTime? addedDate,
          int? shelfLifeDays,
          String? status,
          Value<String?> note = const Value.absent()}) =>
      FoodItemData(
        id: id ?? this.id,
        name: name ?? this.name,
        categoryId: categoryId ?? this.categoryId,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        storage: storage ?? this.storage,
        addedDate: addedDate ?? this.addedDate,
        shelfLifeDays: shelfLifeDays ?? this.shelfLifeDays,
        status: status ?? this.status,
        note: note.present ? note.value : this.note,
      );
  FoodItemData copyWithCompanion(FoodItemsCompanion data) {
    return FoodItemData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      storage: data.storage.present ? data.storage.value : this.storage,
      addedDate: data.addedDate.present ? data.addedDate.value : this.addedDate,
      shelfLifeDays: data.shelfLifeDays.present
          ? data.shelfLifeDays.value
          : this.shelfLifeDays,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodItemData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('storage: $storage, ')
          ..write('addedDate: $addedDate, ')
          ..write('shelfLifeDays: $shelfLifeDays, ')
          ..write('status: $status, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, categoryId, quantity, unit, storage,
      addedDate, shelfLifeDays, status, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodItemData &&
          other.id == this.id &&
          other.name == this.name &&
          other.categoryId == this.categoryId &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.storage == this.storage &&
          other.addedDate == this.addedDate &&
          other.shelfLifeDays == this.shelfLifeDays &&
          other.status == this.status &&
          other.note == this.note);
}

class FoodItemsCompanion extends UpdateCompanion<FoodItemData> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> categoryId;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<Storage> storage;
  final Value<DateTime> addedDate;
  final Value<int> shelfLifeDays;
  final Value<String> status;
  final Value<String?> note;
  const FoodItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.storage = const Value.absent(),
    this.addedDate = const Value.absent(),
    this.shelfLifeDays = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
  });
  FoodItemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int categoryId,
    required double quantity,
    required String unit,
    required Storage storage,
    required DateTime addedDate,
    required int shelfLifeDays,
    this.status = const Value.absent(),
    this.note = const Value.absent(),
  })  : name = Value(name),
        categoryId = Value(categoryId),
        quantity = Value(quantity),
        unit = Value(unit),
        storage = Value(storage),
        addedDate = Value(addedDate),
        shelfLifeDays = Value(shelfLifeDays);
  static Insertable<FoodItemData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? categoryId,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<String>? storage,
    Expression<DateTime>? addedDate,
    Expression<int>? shelfLifeDays,
    Expression<String>? status,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (categoryId != null) 'category_id': categoryId,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (storage != null) 'storage': storage,
      if (addedDate != null) 'added_date': addedDate,
      if (shelfLifeDays != null) 'shelf_life_days': shelfLifeDays,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
    });
  }

  FoodItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? categoryId,
      Value<double>? quantity,
      Value<String>? unit,
      Value<Storage>? storage,
      Value<DateTime>? addedDate,
      Value<int>? shelfLifeDays,
      Value<String>? status,
      Value<String?>? note}) {
    return FoodItemsCompanion(
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
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (storage.present) {
      map['storage'] = Variable<String>(
          $FoodItemsTable.$converterstorage.toSql(storage.value));
    }
    if (addedDate.present) {
      map['added_date'] = Variable<DateTime>(addedDate.value);
    }
    if (shelfLifeDays.present) {
      map['shelf_life_days'] = Variable<int>(shelfLifeDays.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('storage: $storage, ')
          ..write('addedDate: $addedDate, ')
          ..write('shelfLifeDays: $shelfLifeDays, ')
          ..write('status: $status, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $FoodCategoriesTable extends FoodCategories
    with TableInfo<$FoodCategoriesTable, FoodCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chilledDefaultDaysMeta =
      const VerificationMeta('chilledDefaultDays');
  @override
  late final GeneratedColumn<int> chilledDefaultDays = GeneratedColumn<int>(
      'chilled_default_days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _frozenDefaultDaysMeta =
      const VerificationMeta('frozenDefaultDays');
  @override
  late final GeneratedColumn<int> frozenDefaultDays = GeneratedColumn<int>(
      'frozen_default_days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _roomDefaultDaysMeta =
      const VerificationMeta('roomDefaultDays');
  @override
  late final GeneratedColumn<int> roomDefaultDays = GeneratedColumn<int>(
      'room_default_days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, icon, chilledDefaultDays, frozenDefaultDays, roomDefaultDays];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_categories';
  @override
  VerificationContext validateIntegrity(Insertable<FoodCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('chilled_default_days')) {
      context.handle(
          _chilledDefaultDaysMeta,
          chilledDefaultDays.isAcceptableOrUnknown(
              data['chilled_default_days']!, _chilledDefaultDaysMeta));
    } else if (isInserting) {
      context.missing(_chilledDefaultDaysMeta);
    }
    if (data.containsKey('frozen_default_days')) {
      context.handle(
          _frozenDefaultDaysMeta,
          frozenDefaultDays.isAcceptableOrUnknown(
              data['frozen_default_days']!, _frozenDefaultDaysMeta));
    } else if (isInserting) {
      context.missing(_frozenDefaultDaysMeta);
    }
    if (data.containsKey('room_default_days')) {
      context.handle(
          _roomDefaultDaysMeta,
          roomDefaultDays.isAcceptableOrUnknown(
              data['room_default_days']!, _roomDefaultDaysMeta));
    } else if (isInserting) {
      context.missing(_roomDefaultDaysMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      chilledDefaultDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}chilled_default_days'])!,
      frozenDefaultDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}frozen_default_days'])!,
      roomDefaultDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}room_default_days'])!,
    );
  }

  @override
  $FoodCategoriesTable createAlias(String alias) {
    return $FoodCategoriesTable(attachedDatabase, alias);
  }
}

class FoodCategory extends DataClass implements Insertable<FoodCategory> {
  final int id;
  final String name;
  final String icon;
  final int chilledDefaultDays;
  final int frozenDefaultDays;
  final int roomDefaultDays;
  const FoodCategory(
      {required this.id,
      required this.name,
      required this.icon,
      required this.chilledDefaultDays,
      required this.frozenDefaultDays,
      required this.roomDefaultDays});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['chilled_default_days'] = Variable<int>(chilledDefaultDays);
    map['frozen_default_days'] = Variable<int>(frozenDefaultDays);
    map['room_default_days'] = Variable<int>(roomDefaultDays);
    return map;
  }

  FoodCategoriesCompanion toCompanion(bool nullToAbsent) {
    return FoodCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      chilledDefaultDays: Value(chilledDefaultDays),
      frozenDefaultDays: Value(frozenDefaultDays),
      roomDefaultDays: Value(roomDefaultDays),
    );
  }

  factory FoodCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodCategory(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      chilledDefaultDays: serializer.fromJson<int>(json['chilledDefaultDays']),
      frozenDefaultDays: serializer.fromJson<int>(json['frozenDefaultDays']),
      roomDefaultDays: serializer.fromJson<int>(json['roomDefaultDays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'chilledDefaultDays': serializer.toJson<int>(chilledDefaultDays),
      'frozenDefaultDays': serializer.toJson<int>(frozenDefaultDays),
      'roomDefaultDays': serializer.toJson<int>(roomDefaultDays),
    };
  }

  FoodCategory copyWith(
          {int? id,
          String? name,
          String? icon,
          int? chilledDefaultDays,
          int? frozenDefaultDays,
          int? roomDefaultDays}) =>
      FoodCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        chilledDefaultDays: chilledDefaultDays ?? this.chilledDefaultDays,
        frozenDefaultDays: frozenDefaultDays ?? this.frozenDefaultDays,
        roomDefaultDays: roomDefaultDays ?? this.roomDefaultDays,
      );
  FoodCategory copyWithCompanion(FoodCategoriesCompanion data) {
    return FoodCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      chilledDefaultDays: data.chilledDefaultDays.present
          ? data.chilledDefaultDays.value
          : this.chilledDefaultDays,
      frozenDefaultDays: data.frozenDefaultDays.present
          ? data.frozenDefaultDays.value
          : this.frozenDefaultDays,
      roomDefaultDays: data.roomDefaultDays.present
          ? data.roomDefaultDays.value
          : this.roomDefaultDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('chilledDefaultDays: $chilledDefaultDays, ')
          ..write('frozenDefaultDays: $frozenDefaultDays, ')
          ..write('roomDefaultDays: $roomDefaultDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, icon, chilledDefaultDays, frozenDefaultDays, roomDefaultDays);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.chilledDefaultDays == this.chilledDefaultDays &&
          other.frozenDefaultDays == this.frozenDefaultDays &&
          other.roomDefaultDays == this.roomDefaultDays);
}

class FoodCategoriesCompanion extends UpdateCompanion<FoodCategory> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<int> chilledDefaultDays;
  final Value<int> frozenDefaultDays;
  final Value<int> roomDefaultDays;
  const FoodCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.chilledDefaultDays = const Value.absent(),
    this.frozenDefaultDays = const Value.absent(),
    this.roomDefaultDays = const Value.absent(),
  });
  FoodCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String icon,
    required int chilledDefaultDays,
    required int frozenDefaultDays,
    required int roomDefaultDays,
  })  : name = Value(name),
        icon = Value(icon),
        chilledDefaultDays = Value(chilledDefaultDays),
        frozenDefaultDays = Value(frozenDefaultDays),
        roomDefaultDays = Value(roomDefaultDays);
  static Insertable<FoodCategory> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? chilledDefaultDays,
    Expression<int>? frozenDefaultDays,
    Expression<int>? roomDefaultDays,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (chilledDefaultDays != null)
        'chilled_default_days': chilledDefaultDays,
      if (frozenDefaultDays != null) 'frozen_default_days': frozenDefaultDays,
      if (roomDefaultDays != null) 'room_default_days': roomDefaultDays,
    });
  }

  FoodCategoriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? icon,
      Value<int>? chilledDefaultDays,
      Value<int>? frozenDefaultDays,
      Value<int>? roomDefaultDays}) {
    return FoodCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      chilledDefaultDays: chilledDefaultDays ?? this.chilledDefaultDays,
      frozenDefaultDays: frozenDefaultDays ?? this.frozenDefaultDays,
      roomDefaultDays: roomDefaultDays ?? this.roomDefaultDays,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (chilledDefaultDays.present) {
      map['chilled_default_days'] = Variable<int>(chilledDefaultDays.value);
    }
    if (frozenDefaultDays.present) {
      map['frozen_default_days'] = Variable<int>(frozenDefaultDays.value);
    }
    if (roomDefaultDays.present) {
      map['room_default_days'] = Variable<int>(roomDefaultDays.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('chilledDefaultDays: $chilledDefaultDays, ')
          ..write('frozenDefaultDays: $frozenDefaultDays, ')
          ..write('roomDefaultDays: $roomDefaultDays')
          ..write(')'))
        .toString();
  }
}

class $ShelfLifeRulesTable extends ShelfLifeRules
    with TableInfo<$ShelfLifeRulesTable, ShelfLifeRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShelfLifeRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _foodNameMeta =
      const VerificationMeta('foodName');
  @override
  late final GeneratedColumn<String> foodName = GeneratedColumn<String>(
      'food_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _aliasesMeta =
      const VerificationMeta('aliases');
  @override
  late final GeneratedColumn<String> aliases = GeneratedColumn<String>(
      'aliases', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _storageMeta =
      const VerificationMeta('storage');
  @override
  late final GeneratedColumn<String> storage = GeneratedColumn<String>(
      'storage', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _defaultDaysMeta =
      const VerificationMeta('defaultDays');
  @override
  late final GeneratedColumn<int> defaultDays = GeneratedColumn<int>(
      'default_days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, foodName, aliases, storage, defaultDays];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shelf_life_rules';
  @override
  VerificationContext validateIntegrity(Insertable<ShelfLifeRule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('food_name')) {
      context.handle(_foodNameMeta,
          foodName.isAcceptableOrUnknown(data['food_name']!, _foodNameMeta));
    } else if (isInserting) {
      context.missing(_foodNameMeta);
    }
    if (data.containsKey('aliases')) {
      context.handle(_aliasesMeta,
          aliases.isAcceptableOrUnknown(data['aliases']!, _aliasesMeta));
    }
    if (data.containsKey('storage')) {
      context.handle(_storageMeta,
          storage.isAcceptableOrUnknown(data['storage']!, _storageMeta));
    } else if (isInserting) {
      context.missing(_storageMeta);
    }
    if (data.containsKey('default_days')) {
      context.handle(
          _defaultDaysMeta,
          defaultDays.isAcceptableOrUnknown(
              data['default_days']!, _defaultDaysMeta));
    } else if (isInserting) {
      context.missing(_defaultDaysMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShelfLifeRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShelfLifeRule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      foodName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}food_name'])!,
      aliases: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}aliases'])!,
      storage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage'])!,
      defaultDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}default_days'])!,
    );
  }

  @override
  $ShelfLifeRulesTable createAlias(String alias) {
    return $ShelfLifeRulesTable(attachedDatabase, alias);
  }
}

class ShelfLifeRule extends DataClass implements Insertable<ShelfLifeRule> {
  final int id;
  final String foodName;
  final String aliases;
  final String storage;
  final int defaultDays;
  const ShelfLifeRule(
      {required this.id,
      required this.foodName,
      required this.aliases,
      required this.storage,
      required this.defaultDays});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['food_name'] = Variable<String>(foodName);
    map['aliases'] = Variable<String>(aliases);
    map['storage'] = Variable<String>(storage);
    map['default_days'] = Variable<int>(defaultDays);
    return map;
  }

  ShelfLifeRulesCompanion toCompanion(bool nullToAbsent) {
    return ShelfLifeRulesCompanion(
      id: Value(id),
      foodName: Value(foodName),
      aliases: Value(aliases),
      storage: Value(storage),
      defaultDays: Value(defaultDays),
    );
  }

  factory ShelfLifeRule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShelfLifeRule(
      id: serializer.fromJson<int>(json['id']),
      foodName: serializer.fromJson<String>(json['foodName']),
      aliases: serializer.fromJson<String>(json['aliases']),
      storage: serializer.fromJson<String>(json['storage']),
      defaultDays: serializer.fromJson<int>(json['defaultDays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'foodName': serializer.toJson<String>(foodName),
      'aliases': serializer.toJson<String>(aliases),
      'storage': serializer.toJson<String>(storage),
      'defaultDays': serializer.toJson<int>(defaultDays),
    };
  }

  ShelfLifeRule copyWith(
          {int? id,
          String? foodName,
          String? aliases,
          String? storage,
          int? defaultDays}) =>
      ShelfLifeRule(
        id: id ?? this.id,
        foodName: foodName ?? this.foodName,
        aliases: aliases ?? this.aliases,
        storage: storage ?? this.storage,
        defaultDays: defaultDays ?? this.defaultDays,
      );
  ShelfLifeRule copyWithCompanion(ShelfLifeRulesCompanion data) {
    return ShelfLifeRule(
      id: data.id.present ? data.id.value : this.id,
      foodName: data.foodName.present ? data.foodName.value : this.foodName,
      aliases: data.aliases.present ? data.aliases.value : this.aliases,
      storage: data.storage.present ? data.storage.value : this.storage,
      defaultDays:
          data.defaultDays.present ? data.defaultDays.value : this.defaultDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShelfLifeRule(')
          ..write('id: $id, ')
          ..write('foodName: $foodName, ')
          ..write('aliases: $aliases, ')
          ..write('storage: $storage, ')
          ..write('defaultDays: $defaultDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, foodName, aliases, storage, defaultDays);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShelfLifeRule &&
          other.id == this.id &&
          other.foodName == this.foodName &&
          other.aliases == this.aliases &&
          other.storage == this.storage &&
          other.defaultDays == this.defaultDays);
}

class ShelfLifeRulesCompanion extends UpdateCompanion<ShelfLifeRule> {
  final Value<int> id;
  final Value<String> foodName;
  final Value<String> aliases;
  final Value<String> storage;
  final Value<int> defaultDays;
  const ShelfLifeRulesCompanion({
    this.id = const Value.absent(),
    this.foodName = const Value.absent(),
    this.aliases = const Value.absent(),
    this.storage = const Value.absent(),
    this.defaultDays = const Value.absent(),
  });
  ShelfLifeRulesCompanion.insert({
    this.id = const Value.absent(),
    required String foodName,
    this.aliases = const Value.absent(),
    required String storage,
    required int defaultDays,
  })  : foodName = Value(foodName),
        storage = Value(storage),
        defaultDays = Value(defaultDays);
  static Insertable<ShelfLifeRule> custom({
    Expression<int>? id,
    Expression<String>? foodName,
    Expression<String>? aliases,
    Expression<String>? storage,
    Expression<int>? defaultDays,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (foodName != null) 'food_name': foodName,
      if (aliases != null) 'aliases': aliases,
      if (storage != null) 'storage': storage,
      if (defaultDays != null) 'default_days': defaultDays,
    });
  }

  ShelfLifeRulesCompanion copyWith(
      {Value<int>? id,
      Value<String>? foodName,
      Value<String>? aliases,
      Value<String>? storage,
      Value<int>? defaultDays}) {
    return ShelfLifeRulesCompanion(
      id: id ?? this.id,
      foodName: foodName ?? this.foodName,
      aliases: aliases ?? this.aliases,
      storage: storage ?? this.storage,
      defaultDays: defaultDays ?? this.defaultDays,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (foodName.present) {
      map['food_name'] = Variable<String>(foodName.value);
    }
    if (aliases.present) {
      map['aliases'] = Variable<String>(aliases.value);
    }
    if (storage.present) {
      map['storage'] = Variable<String>(storage.value);
    }
    if (defaultDays.present) {
      map['default_days'] = Variable<int>(defaultDays.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShelfLifeRulesCompanion(')
          ..write('id: $id, ')
          ..write('foodName: $foodName, ')
          ..write('aliases: $aliases, ')
          ..write('storage: $storage, ')
          ..write('defaultDays: $defaultDays')
          ..write(')'))
        .toString();
  }
}

class $RecipesTableTable extends RecipesTable
    with TableInfo<$RecipesTableTable, RecipesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<String> steps = GeneratedColumn<String>(
      'steps', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local'));
  @override
  List<GeneratedColumn> get $columns => [id, title, steps, tags, source];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(Insertable<RecipesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('steps')) {
      context.handle(
          _stepsMeta, steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta));
    } else if (isInserting) {
      context.missing(_stepsMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      steps: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}steps'])!,
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
    );
  }

  @override
  $RecipesTableTable createAlias(String alias) {
    return $RecipesTableTable(attachedDatabase, alias);
  }
}

class RecipesTableData extends DataClass
    implements Insertable<RecipesTableData> {
  final int id;
  final String title;
  final String steps;
  final String tags;
  final String source;
  const RecipesTableData(
      {required this.id,
      required this.title,
      required this.steps,
      required this.tags,
      required this.source});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['steps'] = Variable<String>(steps);
    map['tags'] = Variable<String>(tags);
    map['source'] = Variable<String>(source);
    return map;
  }

  RecipesTableCompanion toCompanion(bool nullToAbsent) {
    return RecipesTableCompanion(
      id: Value(id),
      title: Value(title),
      steps: Value(steps),
      tags: Value(tags),
      source: Value(source),
    );
  }

  factory RecipesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipesTableData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      steps: serializer.fromJson<String>(json['steps']),
      tags: serializer.fromJson<String>(json['tags']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'steps': serializer.toJson<String>(steps),
      'tags': serializer.toJson<String>(tags),
      'source': serializer.toJson<String>(source),
    };
  }

  RecipesTableData copyWith(
          {int? id,
          String? title,
          String? steps,
          String? tags,
          String? source}) =>
      RecipesTableData(
        id: id ?? this.id,
        title: title ?? this.title,
        steps: steps ?? this.steps,
        tags: tags ?? this.tags,
        source: source ?? this.source,
      );
  RecipesTableData copyWithCompanion(RecipesTableCompanion data) {
    return RecipesTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      steps: data.steps.present ? data.steps.value : this.steps,
      tags: data.tags.present ? data.tags.value : this.tags,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipesTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('steps: $steps, ')
          ..write('tags: $tags, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, steps, tags, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipesTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.steps == this.steps &&
          other.tags == this.tags &&
          other.source == this.source);
}

class RecipesTableCompanion extends UpdateCompanion<RecipesTableData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> steps;
  final Value<String> tags;
  final Value<String> source;
  const RecipesTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.steps = const Value.absent(),
    this.tags = const Value.absent(),
    this.source = const Value.absent(),
  });
  RecipesTableCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String steps,
    this.tags = const Value.absent(),
    this.source = const Value.absent(),
  })  : title = Value(title),
        steps = Value(steps);
  static Insertable<RecipesTableData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? steps,
    Expression<String>? tags,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (steps != null) 'steps': steps,
      if (tags != null) 'tags': tags,
      if (source != null) 'source': source,
    });
  }

  RecipesTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? steps,
      Value<String>? tags,
      Value<String>? source}) {
    return RecipesTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      steps: steps ?? this.steps,
      tags: tags ?? this.tags,
      source: source ?? this.source,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (steps.present) {
      map['steps'] = Variable<String>(steps.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('steps: $steps, ')
          ..write('tags: $tags, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

class $RecipeIngredientsTableTable extends RecipeIngredientsTable
    with TableInfo<$RecipeIngredientsTableTable, RecipeIngredientsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeIngredientsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _recipeIdMeta =
      const VerificationMeta('recipeId');
  @override
  late final GeneratedColumn<int> recipeId = GeneratedColumn<int>(
      'recipe_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _foodNameMeta =
      const VerificationMeta('foodName');
  @override
  late final GeneratedColumn<String> foodName = GeneratedColumn<String>(
      'food_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, recipeId, foodName, amount, unit, categoryId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_ingredients';
  @override
  VerificationContext validateIntegrity(
      Insertable<RecipeIngredientsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recipe_id')) {
      context.handle(_recipeIdMeta,
          recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta));
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('food_name')) {
      context.handle(_foodNameMeta,
          foodName.isAcceptableOrUnknown(data['food_name']!, _foodNameMeta));
    } else if (isInserting) {
      context.missing(_foodNameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeIngredientsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeIngredientsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      recipeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recipe_id'])!,
      foodName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}food_name'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id']),
    );
  }

  @override
  $RecipeIngredientsTableTable createAlias(String alias) {
    return $RecipeIngredientsTableTable(attachedDatabase, alias);
  }
}

class RecipeIngredientsTableData extends DataClass
    implements Insertable<RecipeIngredientsTableData> {
  final int id;
  final int recipeId;
  final String foodName;
  final double amount;
  final String unit;
  final int? categoryId;
  const RecipeIngredientsTableData(
      {required this.id,
      required this.recipeId,
      required this.foodName,
      required this.amount,
      required this.unit,
      this.categoryId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recipe_id'] = Variable<int>(recipeId);
    map['food_name'] = Variable<String>(foodName);
    map['amount'] = Variable<double>(amount);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    return map;
  }

  RecipeIngredientsTableCompanion toCompanion(bool nullToAbsent) {
    return RecipeIngredientsTableCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      foodName: Value(foodName),
      amount: Value(amount),
      unit: Value(unit),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
    );
  }

  factory RecipeIngredientsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeIngredientsTableData(
      id: serializer.fromJson<int>(json['id']),
      recipeId: serializer.fromJson<int>(json['recipeId']),
      foodName: serializer.fromJson<String>(json['foodName']),
      amount: serializer.fromJson<double>(json['amount']),
      unit: serializer.fromJson<String>(json['unit']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recipeId': serializer.toJson<int>(recipeId),
      'foodName': serializer.toJson<String>(foodName),
      'amount': serializer.toJson<double>(amount),
      'unit': serializer.toJson<String>(unit),
      'categoryId': serializer.toJson<int?>(categoryId),
    };
  }

  RecipeIngredientsTableData copyWith(
          {int? id,
          int? recipeId,
          String? foodName,
          double? amount,
          String? unit,
          Value<int?> categoryId = const Value.absent()}) =>
      RecipeIngredientsTableData(
        id: id ?? this.id,
        recipeId: recipeId ?? this.recipeId,
        foodName: foodName ?? this.foodName,
        amount: amount ?? this.amount,
        unit: unit ?? this.unit,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
      );
  RecipeIngredientsTableData copyWithCompanion(
      RecipeIngredientsTableCompanion data) {
    return RecipeIngredientsTableData(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      foodName: data.foodName.present ? data.foodName.value : this.foodName,
      amount: data.amount.present ? data.amount.value : this.amount,
      unit: data.unit.present ? data.unit.value : this.unit,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredientsTableData(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('foodName: $foodName, ')
          ..write('amount: $amount, ')
          ..write('unit: $unit, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, recipeId, foodName, amount, unit, categoryId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeIngredientsTableData &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.foodName == this.foodName &&
          other.amount == this.amount &&
          other.unit == this.unit &&
          other.categoryId == this.categoryId);
}

class RecipeIngredientsTableCompanion
    extends UpdateCompanion<RecipeIngredientsTableData> {
  final Value<int> id;
  final Value<int> recipeId;
  final Value<String> foodName;
  final Value<double> amount;
  final Value<String> unit;
  final Value<int?> categoryId;
  const RecipeIngredientsTableCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.foodName = const Value.absent(),
    this.amount = const Value.absent(),
    this.unit = const Value.absent(),
    this.categoryId = const Value.absent(),
  });
  RecipeIngredientsTableCompanion.insert({
    this.id = const Value.absent(),
    required int recipeId,
    required String foodName,
    required double amount,
    required String unit,
    this.categoryId = const Value.absent(),
  })  : recipeId = Value(recipeId),
        foodName = Value(foodName),
        amount = Value(amount),
        unit = Value(unit);
  static Insertable<RecipeIngredientsTableData> custom({
    Expression<int>? id,
    Expression<int>? recipeId,
    Expression<String>? foodName,
    Expression<double>? amount,
    Expression<String>? unit,
    Expression<int>? categoryId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (foodName != null) 'food_name': foodName,
      if (amount != null) 'amount': amount,
      if (unit != null) 'unit': unit,
      if (categoryId != null) 'category_id': categoryId,
    });
  }

  RecipeIngredientsTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? recipeId,
      Value<String>? foodName,
      Value<double>? amount,
      Value<String>? unit,
      Value<int?>? categoryId}) {
    return RecipeIngredientsTableCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      foodName: foodName ?? this.foodName,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<int>(recipeId.value);
    }
    if (foodName.present) {
      map['food_name'] = Variable<String>(foodName.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredientsTableCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('foodName: $foodName, ')
          ..write('amount: $amount, ')
          ..write('unit: $unit, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }
}

class $FamilyMembersTable extends FamilyMembers
    with TableInfo<$FamilyMembersTable, FamilyMemberData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamilyMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
      'age', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('other'));
  static const VerificationMeta _dietaryTagsMeta =
      const VerificationMeta('dietaryTags');
  @override
  late final GeneratedColumn<String> dietaryTags = GeneratedColumn<String>(
      'dietary_tags', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _allergiesMeta =
      const VerificationMeta('allergies');
  @override
  late final GeneratedColumn<String> allergies = GeneratedColumn<String>(
      'allergies', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, age, gender, dietaryTags, allergies];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'family_members';
  @override
  VerificationContext validateIntegrity(Insertable<FamilyMemberData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('dietary_tags')) {
      context.handle(
          _dietaryTagsMeta,
          dietaryTags.isAcceptableOrUnknown(
              data['dietary_tags']!, _dietaryTagsMeta));
    }
    if (data.containsKey('allergies')) {
      context.handle(_allergiesMeta,
          allergies.isAcceptableOrUnknown(data['allergies']!, _allergiesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FamilyMemberData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilyMemberData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      age: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age'])!,
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender'])!,
      dietaryTags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dietary_tags'])!,
      allergies: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}allergies'])!,
    );
  }

  @override
  $FamilyMembersTable createAlias(String alias) {
    return $FamilyMembersTable(attachedDatabase, alias);
  }
}

class FamilyMemberData extends DataClass
    implements Insertable<FamilyMemberData> {
  final int id;
  final String name;
  final int age;
  final String gender;
  final String dietaryTags;
  final String allergies;
  const FamilyMemberData(
      {required this.id,
      required this.name,
      required this.age,
      required this.gender,
      required this.dietaryTags,
      required this.allergies});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['age'] = Variable<int>(age);
    map['gender'] = Variable<String>(gender);
    map['dietary_tags'] = Variable<String>(dietaryTags);
    map['allergies'] = Variable<String>(allergies);
    return map;
  }

  FamilyMembersCompanion toCompanion(bool nullToAbsent) {
    return FamilyMembersCompanion(
      id: Value(id),
      name: Value(name),
      age: Value(age),
      gender: Value(gender),
      dietaryTags: Value(dietaryTags),
      allergies: Value(allergies),
    );
  }

  factory FamilyMemberData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilyMemberData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      age: serializer.fromJson<int>(json['age']),
      gender: serializer.fromJson<String>(json['gender']),
      dietaryTags: serializer.fromJson<String>(json['dietaryTags']),
      allergies: serializer.fromJson<String>(json['allergies']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'age': serializer.toJson<int>(age),
      'gender': serializer.toJson<String>(gender),
      'dietaryTags': serializer.toJson<String>(dietaryTags),
      'allergies': serializer.toJson<String>(allergies),
    };
  }

  FamilyMemberData copyWith(
          {int? id,
          String? name,
          int? age,
          String? gender,
          String? dietaryTags,
          String? allergies}) =>
      FamilyMemberData(
        id: id ?? this.id,
        name: name ?? this.name,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        dietaryTags: dietaryTags ?? this.dietaryTags,
        allergies: allergies ?? this.allergies,
      );
  FamilyMemberData copyWithCompanion(FamilyMembersCompanion data) {
    return FamilyMemberData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      age: data.age.present ? data.age.value : this.age,
      gender: data.gender.present ? data.gender.value : this.gender,
      dietaryTags:
          data.dietaryTags.present ? data.dietaryTags.value : this.dietaryTags,
      allergies: data.allergies.present ? data.allergies.value : this.allergies,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilyMemberData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('gender: $gender, ')
          ..write('dietaryTags: $dietaryTags, ')
          ..write('allergies: $allergies')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, age, gender, dietaryTags, allergies);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyMemberData &&
          other.id == this.id &&
          other.name == this.name &&
          other.age == this.age &&
          other.gender == this.gender &&
          other.dietaryTags == this.dietaryTags &&
          other.allergies == this.allergies);
}

class FamilyMembersCompanion extends UpdateCompanion<FamilyMemberData> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> age;
  final Value<String> gender;
  final Value<String> dietaryTags;
  final Value<String> allergies;
  const FamilyMembersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.age = const Value.absent(),
    this.gender = const Value.absent(),
    this.dietaryTags = const Value.absent(),
    this.allergies = const Value.absent(),
  });
  FamilyMembersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int age,
    this.gender = const Value.absent(),
    this.dietaryTags = const Value.absent(),
    this.allergies = const Value.absent(),
  })  : name = Value(name),
        age = Value(age);
  static Insertable<FamilyMemberData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? age,
    Expression<String>? gender,
    Expression<String>? dietaryTags,
    Expression<String>? allergies,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (dietaryTags != null) 'dietary_tags': dietaryTags,
      if (allergies != null) 'allergies': allergies,
    });
  }

  FamilyMembersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? age,
      Value<String>? gender,
      Value<String>? dietaryTags,
      Value<String>? allergies}) {
    return FamilyMembersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      allergies: allergies ?? this.allergies,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (dietaryTags.present) {
      map['dietary_tags'] = Variable<String>(dietaryTags.value);
    }
    if (allergies.present) {
      map['allergies'] = Variable<String>(allergies.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamilyMembersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('gender: $gender, ')
          ..write('dietaryTags: $dietaryTags, ')
          ..write('allergies: $allergies')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FoodItemsTable foodItems = $FoodItemsTable(this);
  late final $FoodCategoriesTable foodCategories = $FoodCategoriesTable(this);
  late final $ShelfLifeRulesTable shelfLifeRules = $ShelfLifeRulesTable(this);
  late final $RecipesTableTable recipesTable = $RecipesTableTable(this);
  late final $RecipeIngredientsTableTable recipeIngredientsTable =
      $RecipeIngredientsTableTable(this);
  late final $FamilyMembersTable familyMembers = $FamilyMembersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        foodItems,
        foodCategories,
        shelfLifeRules,
        recipesTable,
        recipeIngredientsTable,
        familyMembers
      ];
}

typedef $$FoodItemsTableCreateCompanionBuilder = FoodItemsCompanion Function({
  Value<int> id,
  required String name,
  required int categoryId,
  required double quantity,
  required String unit,
  required Storage storage,
  required DateTime addedDate,
  required int shelfLifeDays,
  Value<String> status,
  Value<String?> note,
});
typedef $$FoodItemsTableUpdateCompanionBuilder = FoodItemsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> categoryId,
  Value<double> quantity,
  Value<String> unit,
  Value<Storage> storage,
  Value<DateTime> addedDate,
  Value<int> shelfLifeDays,
  Value<String> status,
  Value<String?> note,
});

class $$FoodItemsTableFilterComposer
    extends Composer<_$AppDatabase, $FoodItemsTable> {
  $$FoodItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Storage, Storage, String> get storage =>
      $composableBuilder(
          column: $table.storage,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get addedDate => $composableBuilder(
      column: $table.addedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get shelfLifeDays => $composableBuilder(
      column: $table.shelfLifeDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$FoodItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodItemsTable> {
  $$FoodItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storage => $composableBuilder(
      column: $table.storage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedDate => $composableBuilder(
      column: $table.addedDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get shelfLifeDays => $composableBuilder(
      column: $table.shelfLifeDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$FoodItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodItemsTable> {
  $$FoodItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Storage, String> get storage =>
      $composableBuilder(column: $table.storage, builder: (column) => column);

  GeneratedColumn<DateTime> get addedDate =>
      $composableBuilder(column: $table.addedDate, builder: (column) => column);

  GeneratedColumn<int> get shelfLifeDays => $composableBuilder(
      column: $table.shelfLifeDays, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$FoodItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FoodItemsTable,
    FoodItemData,
    $$FoodItemsTableFilterComposer,
    $$FoodItemsTableOrderingComposer,
    $$FoodItemsTableAnnotationComposer,
    $$FoodItemsTableCreateCompanionBuilder,
    $$FoodItemsTableUpdateCompanionBuilder,
    (
      FoodItemData,
      BaseReferences<_$AppDatabase, $FoodItemsTable, FoodItemData>
    ),
    FoodItemData,
    PrefetchHooks Function()> {
  $$FoodItemsTableTableManager(_$AppDatabase db, $FoodItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<Storage> storage = const Value.absent(),
            Value<DateTime> addedDate = const Value.absent(),
            Value<int> shelfLifeDays = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              FoodItemsCompanion(
            id: id,
            name: name,
            categoryId: categoryId,
            quantity: quantity,
            unit: unit,
            storage: storage,
            addedDate: addedDate,
            shelfLifeDays: shelfLifeDays,
            status: status,
            note: note,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required int categoryId,
            required double quantity,
            required String unit,
            required Storage storage,
            required DateTime addedDate,
            required int shelfLifeDays,
            Value<String> status = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              FoodItemsCompanion.insert(
            id: id,
            name: name,
            categoryId: categoryId,
            quantity: quantity,
            unit: unit,
            storage: storage,
            addedDate: addedDate,
            shelfLifeDays: shelfLifeDays,
            status: status,
            note: note,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FoodItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FoodItemsTable,
    FoodItemData,
    $$FoodItemsTableFilterComposer,
    $$FoodItemsTableOrderingComposer,
    $$FoodItemsTableAnnotationComposer,
    $$FoodItemsTableCreateCompanionBuilder,
    $$FoodItemsTableUpdateCompanionBuilder,
    (
      FoodItemData,
      BaseReferences<_$AppDatabase, $FoodItemsTable, FoodItemData>
    ),
    FoodItemData,
    PrefetchHooks Function()>;
typedef $$FoodCategoriesTableCreateCompanionBuilder = FoodCategoriesCompanion
    Function({
  Value<int> id,
  required String name,
  required String icon,
  required int chilledDefaultDays,
  required int frozenDefaultDays,
  required int roomDefaultDays,
});
typedef $$FoodCategoriesTableUpdateCompanionBuilder = FoodCategoriesCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> icon,
  Value<int> chilledDefaultDays,
  Value<int> frozenDefaultDays,
  Value<int> roomDefaultDays,
});

class $$FoodCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $FoodCategoriesTable> {
  $$FoodCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chilledDefaultDays => $composableBuilder(
      column: $table.chilledDefaultDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get frozenDefaultDays => $composableBuilder(
      column: $table.frozenDefaultDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get roomDefaultDays => $composableBuilder(
      column: $table.roomDefaultDays,
      builder: (column) => ColumnFilters(column));
}

class $$FoodCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodCategoriesTable> {
  $$FoodCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chilledDefaultDays => $composableBuilder(
      column: $table.chilledDefaultDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get frozenDefaultDays => $composableBuilder(
      column: $table.frozenDefaultDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get roomDefaultDays => $composableBuilder(
      column: $table.roomDefaultDays,
      builder: (column) => ColumnOrderings(column));
}

class $$FoodCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodCategoriesTable> {
  $$FoodCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get chilledDefaultDays => $composableBuilder(
      column: $table.chilledDefaultDays, builder: (column) => column);

  GeneratedColumn<int> get frozenDefaultDays => $composableBuilder(
      column: $table.frozenDefaultDays, builder: (column) => column);

  GeneratedColumn<int> get roomDefaultDays => $composableBuilder(
      column: $table.roomDefaultDays, builder: (column) => column);
}

class $$FoodCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FoodCategoriesTable,
    FoodCategory,
    $$FoodCategoriesTableFilterComposer,
    $$FoodCategoriesTableOrderingComposer,
    $$FoodCategoriesTableAnnotationComposer,
    $$FoodCategoriesTableCreateCompanionBuilder,
    $$FoodCategoriesTableUpdateCompanionBuilder,
    (
      FoodCategory,
      BaseReferences<_$AppDatabase, $FoodCategoriesTable, FoodCategory>
    ),
    FoodCategory,
    PrefetchHooks Function()> {
  $$FoodCategoriesTableTableManager(
      _$AppDatabase db, $FoodCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<int> chilledDefaultDays = const Value.absent(),
            Value<int> frozenDefaultDays = const Value.absent(),
            Value<int> roomDefaultDays = const Value.absent(),
          }) =>
              FoodCategoriesCompanion(
            id: id,
            name: name,
            icon: icon,
            chilledDefaultDays: chilledDefaultDays,
            frozenDefaultDays: frozenDefaultDays,
            roomDefaultDays: roomDefaultDays,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String icon,
            required int chilledDefaultDays,
            required int frozenDefaultDays,
            required int roomDefaultDays,
          }) =>
              FoodCategoriesCompanion.insert(
            id: id,
            name: name,
            icon: icon,
            chilledDefaultDays: chilledDefaultDays,
            frozenDefaultDays: frozenDefaultDays,
            roomDefaultDays: roomDefaultDays,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FoodCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FoodCategoriesTable,
    FoodCategory,
    $$FoodCategoriesTableFilterComposer,
    $$FoodCategoriesTableOrderingComposer,
    $$FoodCategoriesTableAnnotationComposer,
    $$FoodCategoriesTableCreateCompanionBuilder,
    $$FoodCategoriesTableUpdateCompanionBuilder,
    (
      FoodCategory,
      BaseReferences<_$AppDatabase, $FoodCategoriesTable, FoodCategory>
    ),
    FoodCategory,
    PrefetchHooks Function()>;
typedef $$ShelfLifeRulesTableCreateCompanionBuilder = ShelfLifeRulesCompanion
    Function({
  Value<int> id,
  required String foodName,
  Value<String> aliases,
  required String storage,
  required int defaultDays,
});
typedef $$ShelfLifeRulesTableUpdateCompanionBuilder = ShelfLifeRulesCompanion
    Function({
  Value<int> id,
  Value<String> foodName,
  Value<String> aliases,
  Value<String> storage,
  Value<int> defaultDays,
});

class $$ShelfLifeRulesTableFilterComposer
    extends Composer<_$AppDatabase, $ShelfLifeRulesTable> {
  $$ShelfLifeRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get foodName => $composableBuilder(
      column: $table.foodName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aliases => $composableBuilder(
      column: $table.aliases, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storage => $composableBuilder(
      column: $table.storage, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get defaultDays => $composableBuilder(
      column: $table.defaultDays, builder: (column) => ColumnFilters(column));
}

class $$ShelfLifeRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $ShelfLifeRulesTable> {
  $$ShelfLifeRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get foodName => $composableBuilder(
      column: $table.foodName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aliases => $composableBuilder(
      column: $table.aliases, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storage => $composableBuilder(
      column: $table.storage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get defaultDays => $composableBuilder(
      column: $table.defaultDays, builder: (column) => ColumnOrderings(column));
}

class $$ShelfLifeRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShelfLifeRulesTable> {
  $$ShelfLifeRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get foodName =>
      $composableBuilder(column: $table.foodName, builder: (column) => column);

  GeneratedColumn<String> get aliases =>
      $composableBuilder(column: $table.aliases, builder: (column) => column);

  GeneratedColumn<String> get storage =>
      $composableBuilder(column: $table.storage, builder: (column) => column);

  GeneratedColumn<int> get defaultDays => $composableBuilder(
      column: $table.defaultDays, builder: (column) => column);
}

class $$ShelfLifeRulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShelfLifeRulesTable,
    ShelfLifeRule,
    $$ShelfLifeRulesTableFilterComposer,
    $$ShelfLifeRulesTableOrderingComposer,
    $$ShelfLifeRulesTableAnnotationComposer,
    $$ShelfLifeRulesTableCreateCompanionBuilder,
    $$ShelfLifeRulesTableUpdateCompanionBuilder,
    (
      ShelfLifeRule,
      BaseReferences<_$AppDatabase, $ShelfLifeRulesTable, ShelfLifeRule>
    ),
    ShelfLifeRule,
    PrefetchHooks Function()> {
  $$ShelfLifeRulesTableTableManager(
      _$AppDatabase db, $ShelfLifeRulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShelfLifeRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShelfLifeRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShelfLifeRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> foodName = const Value.absent(),
            Value<String> aliases = const Value.absent(),
            Value<String> storage = const Value.absent(),
            Value<int> defaultDays = const Value.absent(),
          }) =>
              ShelfLifeRulesCompanion(
            id: id,
            foodName: foodName,
            aliases: aliases,
            storage: storage,
            defaultDays: defaultDays,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String foodName,
            Value<String> aliases = const Value.absent(),
            required String storage,
            required int defaultDays,
          }) =>
              ShelfLifeRulesCompanion.insert(
            id: id,
            foodName: foodName,
            aliases: aliases,
            storage: storage,
            defaultDays: defaultDays,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ShelfLifeRulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ShelfLifeRulesTable,
    ShelfLifeRule,
    $$ShelfLifeRulesTableFilterComposer,
    $$ShelfLifeRulesTableOrderingComposer,
    $$ShelfLifeRulesTableAnnotationComposer,
    $$ShelfLifeRulesTableCreateCompanionBuilder,
    $$ShelfLifeRulesTableUpdateCompanionBuilder,
    (
      ShelfLifeRule,
      BaseReferences<_$AppDatabase, $ShelfLifeRulesTable, ShelfLifeRule>
    ),
    ShelfLifeRule,
    PrefetchHooks Function()>;
typedef $$RecipesTableTableCreateCompanionBuilder = RecipesTableCompanion
    Function({
  Value<int> id,
  required String title,
  required String steps,
  Value<String> tags,
  Value<String> source,
});
typedef $$RecipesTableTableUpdateCompanionBuilder = RecipesTableCompanion
    Function({
  Value<int> id,
  Value<String> title,
  Value<String> steps,
  Value<String> tags,
  Value<String> source,
});

class $$RecipesTableTableFilterComposer
    extends Composer<_$AppDatabase, $RecipesTableTable> {
  $$RecipesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get steps => $composableBuilder(
      column: $table.steps, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));
}

class $$RecipesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipesTableTable> {
  $$RecipesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get steps => $composableBuilder(
      column: $table.steps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));
}

class $$RecipesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipesTableTable> {
  $$RecipesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$RecipesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecipesTableTable,
    RecipesTableData,
    $$RecipesTableTableFilterComposer,
    $$RecipesTableTableOrderingComposer,
    $$RecipesTableTableAnnotationComposer,
    $$RecipesTableTableCreateCompanionBuilder,
    $$RecipesTableTableUpdateCompanionBuilder,
    (
      RecipesTableData,
      BaseReferences<_$AppDatabase, $RecipesTableTable, RecipesTableData>
    ),
    RecipesTableData,
    PrefetchHooks Function()> {
  $$RecipesTableTableTableManager(_$AppDatabase db, $RecipesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> steps = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<String> source = const Value.absent(),
          }) =>
              RecipesTableCompanion(
            id: id,
            title: title,
            steps: steps,
            tags: tags,
            source: source,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required String steps,
            Value<String> tags = const Value.absent(),
            Value<String> source = const Value.absent(),
          }) =>
              RecipesTableCompanion.insert(
            id: id,
            title: title,
            steps: steps,
            tags: tags,
            source: source,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RecipesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecipesTableTable,
    RecipesTableData,
    $$RecipesTableTableFilterComposer,
    $$RecipesTableTableOrderingComposer,
    $$RecipesTableTableAnnotationComposer,
    $$RecipesTableTableCreateCompanionBuilder,
    $$RecipesTableTableUpdateCompanionBuilder,
    (
      RecipesTableData,
      BaseReferences<_$AppDatabase, $RecipesTableTable, RecipesTableData>
    ),
    RecipesTableData,
    PrefetchHooks Function()>;
typedef $$RecipeIngredientsTableTableCreateCompanionBuilder
    = RecipeIngredientsTableCompanion Function({
  Value<int> id,
  required int recipeId,
  required String foodName,
  required double amount,
  required String unit,
  Value<int?> categoryId,
});
typedef $$RecipeIngredientsTableTableUpdateCompanionBuilder
    = RecipeIngredientsTableCompanion Function({
  Value<int> id,
  Value<int> recipeId,
  Value<String> foodName,
  Value<double> amount,
  Value<String> unit,
  Value<int?> categoryId,
});

class $$RecipeIngredientsTableTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTableTable> {
  $$RecipeIngredientsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recipeId => $composableBuilder(
      column: $table.recipeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get foodName => $composableBuilder(
      column: $table.foodName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));
}

class $$RecipeIngredientsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTableTable> {
  $$RecipeIngredientsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recipeId => $composableBuilder(
      column: $table.recipeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get foodName => $composableBuilder(
      column: $table.foodName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));
}

class $$RecipeIngredientsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTableTable> {
  $$RecipeIngredientsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<String> get foodName =>
      $composableBuilder(column: $table.foodName, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);
}

class $$RecipeIngredientsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecipeIngredientsTableTable,
    RecipeIngredientsTableData,
    $$RecipeIngredientsTableTableFilterComposer,
    $$RecipeIngredientsTableTableOrderingComposer,
    $$RecipeIngredientsTableTableAnnotationComposer,
    $$RecipeIngredientsTableTableCreateCompanionBuilder,
    $$RecipeIngredientsTableTableUpdateCompanionBuilder,
    (
      RecipeIngredientsTableData,
      BaseReferences<_$AppDatabase, $RecipeIngredientsTableTable,
          RecipeIngredientsTableData>
    ),
    RecipeIngredientsTableData,
    PrefetchHooks Function()> {
  $$RecipeIngredientsTableTableTableManager(
      _$AppDatabase db, $RecipeIngredientsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeIngredientsTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeIngredientsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeIngredientsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> recipeId = const Value.absent(),
            Value<String> foodName = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
          }) =>
              RecipeIngredientsTableCompanion(
            id: id,
            recipeId: recipeId,
            foodName: foodName,
            amount: amount,
            unit: unit,
            categoryId: categoryId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int recipeId,
            required String foodName,
            required double amount,
            required String unit,
            Value<int?> categoryId = const Value.absent(),
          }) =>
              RecipeIngredientsTableCompanion.insert(
            id: id,
            recipeId: recipeId,
            foodName: foodName,
            amount: amount,
            unit: unit,
            categoryId: categoryId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RecipeIngredientsTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $RecipeIngredientsTableTable,
        RecipeIngredientsTableData,
        $$RecipeIngredientsTableTableFilterComposer,
        $$RecipeIngredientsTableTableOrderingComposer,
        $$RecipeIngredientsTableTableAnnotationComposer,
        $$RecipeIngredientsTableTableCreateCompanionBuilder,
        $$RecipeIngredientsTableTableUpdateCompanionBuilder,
        (
          RecipeIngredientsTableData,
          BaseReferences<_$AppDatabase, $RecipeIngredientsTableTable,
              RecipeIngredientsTableData>
        ),
        RecipeIngredientsTableData,
        PrefetchHooks Function()>;
typedef $$FamilyMembersTableCreateCompanionBuilder = FamilyMembersCompanion
    Function({
  Value<int> id,
  required String name,
  required int age,
  Value<String> gender,
  Value<String> dietaryTags,
  Value<String> allergies,
});
typedef $$FamilyMembersTableUpdateCompanionBuilder = FamilyMembersCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<int> age,
  Value<String> gender,
  Value<String> dietaryTags,
  Value<String> allergies,
});

class $$FamilyMembersTableFilterComposer
    extends Composer<_$AppDatabase, $FamilyMembersTable> {
  $$FamilyMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dietaryTags => $composableBuilder(
      column: $table.dietaryTags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get allergies => $composableBuilder(
      column: $table.allergies, builder: (column) => ColumnFilters(column));
}

class $$FamilyMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $FamilyMembersTable> {
  $$FamilyMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dietaryTags => $composableBuilder(
      column: $table.dietaryTags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get allergies => $composableBuilder(
      column: $table.allergies, builder: (column) => ColumnOrderings(column));
}

class $$FamilyMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FamilyMembersTable> {
  $$FamilyMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get dietaryTags => $composableBuilder(
      column: $table.dietaryTags, builder: (column) => column);

  GeneratedColumn<String> get allergies =>
      $composableBuilder(column: $table.allergies, builder: (column) => column);
}

class $$FamilyMembersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FamilyMembersTable,
    FamilyMemberData,
    $$FamilyMembersTableFilterComposer,
    $$FamilyMembersTableOrderingComposer,
    $$FamilyMembersTableAnnotationComposer,
    $$FamilyMembersTableCreateCompanionBuilder,
    $$FamilyMembersTableUpdateCompanionBuilder,
    (
      FamilyMemberData,
      BaseReferences<_$AppDatabase, $FamilyMembersTable, FamilyMemberData>
    ),
    FamilyMemberData,
    PrefetchHooks Function()> {
  $$FamilyMembersTableTableManager(_$AppDatabase db, $FamilyMembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamilyMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamilyMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamilyMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> age = const Value.absent(),
            Value<String> gender = const Value.absent(),
            Value<String> dietaryTags = const Value.absent(),
            Value<String> allergies = const Value.absent(),
          }) =>
              FamilyMembersCompanion(
            id: id,
            name: name,
            age: age,
            gender: gender,
            dietaryTags: dietaryTags,
            allergies: allergies,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required int age,
            Value<String> gender = const Value.absent(),
            Value<String> dietaryTags = const Value.absent(),
            Value<String> allergies = const Value.absent(),
          }) =>
              FamilyMembersCompanion.insert(
            id: id,
            name: name,
            age: age,
            gender: gender,
            dietaryTags: dietaryTags,
            allergies: allergies,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FamilyMembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FamilyMembersTable,
    FamilyMemberData,
    $$FamilyMembersTableFilterComposer,
    $$FamilyMembersTableOrderingComposer,
    $$FamilyMembersTableAnnotationComposer,
    $$FamilyMembersTableCreateCompanionBuilder,
    $$FamilyMembersTableUpdateCompanionBuilder,
    (
      FamilyMemberData,
      BaseReferences<_$AppDatabase, $FamilyMembersTable, FamilyMemberData>
    ),
    FamilyMemberData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FoodItemsTableTableManager get foodItems =>
      $$FoodItemsTableTableManager(_db, _db.foodItems);
  $$FoodCategoriesTableTableManager get foodCategories =>
      $$FoodCategoriesTableTableManager(_db, _db.foodCategories);
  $$ShelfLifeRulesTableTableManager get shelfLifeRules =>
      $$ShelfLifeRulesTableTableManager(_db, _db.shelfLifeRules);
  $$RecipesTableTableTableManager get recipesTable =>
      $$RecipesTableTableTableManager(_db, _db.recipesTable);
  $$RecipeIngredientsTableTableTableManager get recipeIngredientsTable =>
      $$RecipeIngredientsTableTableTableManager(
          _db, _db.recipeIngredientsTable);
  $$FamilyMembersTableTableManager get familyMembers =>
      $$FamilyMembersTableTableManager(_db, _db.familyMembers);
}
