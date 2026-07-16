import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fridge_manager/core/theme/app_theme.dart';
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
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(_editing == null ? '添加食材' : '编辑食材')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _SectionLabel(text: '基本信息'),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            autofocus: _editing == null,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: '食材名称',
              prefixIcon: Icon(Icons.label_outline_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _qty,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '数量',
                  prefixIcon: Icon(Icons.scale_outlined),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _unit,
                decoration: const InputDecoration(labelText: '单位'),
              ),
            ),
          ]),
          const SizedBox(height: 24),

          _SectionLabel(text: '存储位置'),
          const SizedBox(height: 8),
          SegmentedButton<Storage>(
            segments: [
              for (final s in Storage.values)
                ButtonSegment(
                  value: s,
                  icon: Icon(AppTheme.storageIcon(s.label), size: 18),
                  label: Text(s.label),
                ),
            ],
            selected: {_storage},
            onSelectionChanged: (s) => setState(() => _storage = s.first),
          ),
          const SizedBox(height: 24),

          _SectionLabel(text: '保质期'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SwitchListTile(
                title: const Text('使用参考表默认值'),
                subtitle: Text(
                  _autoShelf ? '系统会根据食材和存储位置自动估算' : '手动设置保质期天数',
                  style: TextStyle(fontSize: 12, color: scheme.outline),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                value: _autoShelf,
                onChanged: (v) => setState(() => _autoShelf = v),
              ),
            ),
          ),
          if (!_autoShelf) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _shelf,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '保质期（天）',
                prefixIcon: Icon(Icons.timer_outlined),
              ),
            ),
          ],
          const SizedBox(height: 32),
          FilledButton.icon(
            icon: const Icon(Icons.check_rounded),
            label: Text(_editing == null ? '保存到冰箱' : '保存修改'),
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  String _formatQty(double q) =>
      q == q.roundToDouble() ? q.toInt().toString() : q.toString();

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入食材名称')),
      );
      return;
    }
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
        shelfLifeDays: _autoShelf
            ? _editing!.shelfLifeDays
            : (shelf ?? _editing!.shelfLifeDays),
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
      final id = await repo.addWithDefaultShelfLife(
        name: name,
        categoryId: 0,
        quantity: qty,
        unit: unit,
        storage: _storage,
        addedDate: DateTime.now(),
      );
      final item = await repo.getById(id);
      await repo.update(
          item.copyWith(shelfLifeDays: shelf ?? item.shelfLifeDays));
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editing == null ? '已添加 $name' : '已更新 $name'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/fridge');
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }
}
