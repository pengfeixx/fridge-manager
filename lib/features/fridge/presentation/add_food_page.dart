import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/food_item.dart';
import 'package:fridge_manager/features/fridge/providers/fridge_providers.dart';

class AddFoodPage extends ConsumerStatefulWidget {
  final FoodItem? editingItem;
  const AddFoodPage({super.key, this.editingItem});
  @override
  ConsumerState<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends ConsumerState<AddFoodPage> {
  final _name = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _unit = TextEditingController(text: '份');
  final _shelf = TextEditingController();
  Storage _storage = Storage.chilled;
  bool _autoShelf = true;

  FoodItem? get _editing => widget.editingItem;

  @override
  void initState() {
    super.initState();
    final e = _editing;
    if (e != null) {
      _name.text = e.name;
      _qty.text = _formatQty(e.quantity);
      _unit.text = e.unit;
      _storage = e.storage;
      _shelf.text = e.shelfLifeDays.toString();
      _autoShelf = false;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
    _unit.dispose();
    _shelf.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final rules = ref.read(foodRepositoryProvider).getShelfLifeRules();
    return Scaffold(
      appBar: AppBar(
          title: Text(_editing == null ? '添加食材' : '编辑食材')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(
                labelText: '食材名称', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _qty,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: '数量', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _unit,
                decoration: const InputDecoration(
                    labelText: '单位', border: OutlineInputBorder()),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          SegmentedButton<Storage>(
            segments: [
              for (final s in Storage.values)
                ButtonSegment(value: s, label: Text(s.label))
            ],
            selected: {_storage},
            onSelectionChanged: (s) => setState(() => _storage = s.first),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('使用参考表默认保质期'),
            value: _autoShelf,
            onChanged: (v) => setState(() => _autoShelf = v),
          ),
          if (!_autoShelf)
            TextField(
              controller: _shelf,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: '保质期（天）', border: OutlineInputBorder()),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: Text(_editing == null ? '保存' : '保存修改'),
          ),
        ],
      ),
      floatingActionButton: null,
    );
  }

  String _formatQty(double q) =>
      q == q.roundToDouble() ? q.toInt().toString() : q.toString();

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final repo = ref.read(foodRepositoryProvider);
    final qty = double.tryParse(_qty.text) ?? 1;
    final unit = _unit.text.trim();
    final shelf = int.tryParse(_shelf.text);

    if (_editing != null) {
      await repo.update(_editing!.copyWith(
        name: name,
        quantity: qty,
        unit: unit,
        storage: _storage,
        shelfLifeDays: _autoShelf ? _editing!.shelfLifeDays : (shelf ?? _editing!.shelfLifeDays),
      ));
    } else if (_autoShelf) {
      await repo.addWithDefaultShelfLife(
        name: name,
        categoryId: 0,
        quantity: qty,
        unit: unit,
        storage: _storage,
        addedDate: DateTime.now(),
      );
    } else {
      // 手动保质期：先按默认保质期入库，再用 update 覆盖 shelfLifeDays。
      final id = await repo.addWithDefaultShelfLife(
        name: name,
        categoryId: 0,
        quantity: qty,
        unit: unit,
        storage: _storage,
        addedDate: DateTime.now(),
      );
      final item = await repo.getById(id);
      await repo.update(item.copyWith(
          shelfLifeDays: shelf ?? item.shelfLifeDays));
    }
    if (mounted) context.go('/fridge');
  }
}
