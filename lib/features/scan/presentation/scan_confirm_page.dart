import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fridge_manager/domain/ai/food_recognition.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/features/scan/providers/scan_providers.dart';
import 'package:fridge_manager/features/fridge/providers/fridge_providers.dart';

class ScanConfirmPage extends ConsumerStatefulWidget {
  const ScanConfirmPage({super.key});
  @override
  ConsumerState<ScanConfirmPage> createState() => _ScanConfirmPageState();
}

class _ScanConfirmPageState extends ConsumerState<ScanConfirmPage> {
  late List<RecognizedFood> _foods;

  @override
  void initState() {
    super.initState();
    _foods = List.from(ref.read(scanResultProvider));
  }

  void _updateFood(int index, RecognizedFood food) {
    setState(() => _foods[index] = food);
  }

  void _removeFood(int index) {
    setState(() => _foods.removeAt(index));
  }

  Future<void> _addAll() async {
    final repo = ref.read(foodRepositoryProvider);
    for (final food in _foods) {
      await repo.addWithDefaultShelfLife(
        name: food.name,
        categoryId: 0,
        quantity: food.quantity,
        unit: food.unit,
        storage: Storage.chilled,
        addedDate: DateTime.now(),
      );
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已添加 ${_foods.length} 种食材'),
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
            onPressed: _foods.isEmpty ? null : _addAll,
            tooltip: '全部入库',
          ),
        ],
      ),
      body: _foods.isEmpty
          ? const Center(child: Text('没有识别到食材'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _foods.length,
              itemBuilder: (_, i) => _FoodEditCard(
                food: _foods[i],
                onChanged: (f) => _updateFood(i, f),
                onRemove: () => _removeFood(i),
              ),
            ),
      bottomNavigationBar: _foods.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: _addAll,
                  icon: const Icon(Icons.check_rounded),
                  label: Text('确认入库（${_foods.length} 项）'),
                ),
              ),
            ),
    );
  }
}

class _FoodEditCard extends StatelessWidget {
  final RecognizedFood food;
  final ValueChanged<RecognizedFood> onChanged;
  final VoidCallback onRemove;
  const _FoodEditCard(
      {required this.food, required this.onChanged, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController(text: food.name);
    final qtyCtrl = TextEditingController(
        text: food.quantity == food.quantity.roundToDouble()
            ? food.quantity.toInt().toString()
            : food.quantity.toString());
    final unitCtrl = TextEditingController(text: food.unit);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                    labelText: '名称', isDense: true),
                onChanged: (v) => onChanged(food.copyWith(name: v)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: '数量', isDense: true),
                onChanged: (v) => onChanged(food.copyWith(
                    quantity: double.tryParse(v) ?? food.quantity)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: unitCtrl,
                decoration: const InputDecoration(
                    labelText: '单位', isDense: true),
                onChanged: (v) => onChanged(food.copyWith(unit: v)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
