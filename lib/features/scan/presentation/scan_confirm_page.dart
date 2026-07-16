import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fridge_manager/domain/ai/food_recognition.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/features/scan/providers/scan_providers.dart';
import 'package:fridge_manager/features/fridge/providers/fridge_providers.dart';

/// 可编辑的识别食材及其存储位置。
class _EditableFood {
  final RecognizedFood food;
  final Storage storage;
  const _EditableFood({required this.food, this.storage = Storage.chilled});

  _EditableFood copyWith({RecognizedFood? food, Storage? storage}) =>
      _EditableFood(
        food: food ?? this.food,
        storage: storage ?? this.storage,
      );
}

class ScanConfirmPage extends ConsumerStatefulWidget {
  const ScanConfirmPage({super.key});
  @override
  ConsumerState<ScanConfirmPage> createState() => _ScanConfirmPageState();
}

class _ScanConfirmPageState extends ConsumerState<ScanConfirmPage> {
  late List<_EditableFood> _items;

  @override
  void initState() {
    super.initState();
    _items = ref
        .read(scanResultProvider)
        .map((f) => _EditableFood(food: f))
        .toList();
  }

  void _updateItem(int index, _EditableFood item) {
    setState(() => _items[index] = item);
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  Future<void> _addAll() async {
    final repo = ref.read(foodRepositoryProvider);
    for (final item in _items) {
      await repo.addWithDefaultShelfLife(
        name: item.food.name,
        categoryId: 0,
        quantity: item.food.quantity,
        unit: item.food.unit,
        storage: item.storage,
        addedDate: DateTime.now(),
      );
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已添加 ${_items.length} 种食材'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      ref.read(scanResultProvider.notifier).state = [];
      context.go('/fridge');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('确认食材'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _items.isEmpty ? null : _addAll,
            tooltip: '全部入库',
          ),
        ],
      ),
      body: _items.isEmpty
          ? const Center(child: Text('没有识别到食材'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (_, i) => _FoodEditCard(
                item: _items[i],
                onChanged: (item) => _updateItem(i, item),
                onRemove: () => _removeItem(i),
              ),
            ),
      bottomNavigationBar: _items.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: _addAll,
                  icon: const Icon(Icons.check_rounded),
                  label: Text('确认入库（${_items.length} 项）'),
                ),
              ),
            ),
    );
  }
}

class _FoodEditCard extends StatefulWidget {
  final _EditableFood item;
  final ValueChanged<_EditableFood> onChanged;
  final VoidCallback onRemove;
  const _FoodEditCard(
      {required this.item, required this.onChanged, required this.onRemove});

  @override
  State<_FoodEditCard> createState() => _FoodEditCardState();
}

class _FoodEditCardState extends State<_FoodEditCard> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _unitCtrl;

  @override
  void initState() {
    super.initState();
    final food = widget.item.food;
    _nameCtrl = TextEditingController(text: food.name);
    _qtyCtrl = TextEditingController(
        text: food.quantity == food.quantity.roundToDouble()
            ? food.quantity.toInt().toString()
            : food.quantity.toString());
    _unitCtrl = TextEditingController(text: food.unit);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.item.food;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                        labelText: '名称', isDense: true),
                    onChanged: (v) => widget.onChanged(
                        widget.item.copyWith(food: food.copyWith(name: v))),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: '数量', isDense: true),
                    onChanged: (v) => widget.onChanged(widget.item.copyWith(
                        food: food.copyWith(
                            quantity: double.tryParse(v) ?? food.quantity))),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _unitCtrl,
                    decoration: const InputDecoration(
                        labelText: '单位', isDense: true),
                    onChanged: (v) => widget.onChanged(widget.item.copyWith(
                        food: food.copyWith(unit: v))),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            Row(
              children: [
                const Text('存储'),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<Storage>(
                    initialValue: widget.item.storage,
                    isDense: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                    ),
                    items: [
                      for (final s in Storage.values)
                        DropdownMenuItem(
                          value: s,
                          child: Text(s.label),
                        ),
                    ],
                    onChanged: (s) {
                      if (s != null) {
                        widget.onChanged(widget.item.copyWith(storage: s));
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
