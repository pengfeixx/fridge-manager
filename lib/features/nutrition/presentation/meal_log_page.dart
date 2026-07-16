import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/meal_log.dart';
import 'package:fridge_manager/domain/entities/nutrition_guide.dart';
import 'package:fridge_manager/features/nutrition/providers/nutrition_providers.dart';

Future<void> showMealLogPage(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => const _MealLogSheet(),
  ).then((log) {
    if (log is MealLog) {
      ref.read(mealLogRepositoryProvider).add(log);
    }
  });
}

class _MealLogSheet extends StatefulWidget {
  const _MealLogSheet();
  @override
  State<_MealLogSheet> createState() => _MealLogSheetState();
}

class _MealLogSheetState extends State<_MealLogSheet> {
  MealType _mealType = MealType.lunch;
  DateTime _date = DateTime.now();
  final _entries = <_EntryDraft>[];

  @override
  void initState() {
    super.initState();
    _entries.add(_EntryDraft());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(children: [
              const Text('记录饮食',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context)),
            ]),
          ),
          const Divider(),
          Flexible(
              child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              Row(children: [
                Expanded(
                    child: SegmentedButton<MealType>(
                  segments: const [
                    ButtonSegment(value: MealType.breakfast, label: Text('早')),
                    ButtonSegment(value: MealType.lunch, label: Text('午')),
                    ButtonSegment(value: MealType.dinner, label: Text('晚')),
                    ButtonSegment(value: MealType.snack, label: Text('加餐')),
                  ],
                  selected: {_mealType},
                  onSelectionChanged: (s) => setState(() => _mealType = s.first),
                )),
              ]),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now(),
                  );
                  if (d != null) setState(() => _date = d);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.calendar_today_rounded)),
                  child: Text('${_date.month}月${_date.day}日'),
                ),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < _entries.length; i++)
                _EntryRow(
                  key: ValueKey(_entries[i]),
                  draft: _entries[i],
                  onChanged: (d) => _entries[i] = d,
                  onRemove: () => setState(() => _entries.removeAt(i)),
                ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _entries.add(_EntryDraft())),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('添加一项'),
                ),
              ),
            ],
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: const Text('保存记录'),
            ),
          ),
        ]),
      ),
    );
  }

  void _save() {
    final valid = _entries
        .where((e) => e.amount > 0)
        .map((e) => MealEntry(category: e.category, amountGram: e.amount))
        .toList();
    if (valid.isEmpty) {
      Navigator.pop(context);
      return;
    }
    Navigator.pop(context,
        MealLog(date: _date, mealType: _mealType, entries: valid));
  }
}

class _EntryDraft {
  NutritionCategory category = NutritionCategory.vegetables;
  double amount = 100;
}

/// 用 StatefulWidget 持有持久的 TextEditingController，
/// 避免在 build() 中重复创建导致输入时光标跳动。
class _EntryRow extends StatefulWidget {
  final _EntryDraft draft;
  final ValueChanged<_EntryDraft> onChanged;
  final VoidCallback onRemove;
  const _EntryRow({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_EntryRow> createState() => _EntryRowState();
}

class _EntryRowState extends State<_EntryRow> {
  late final TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    _amountCtrl =
        TextEditingController(text: widget.draft.amount.round().toString());
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        DropdownButton<NutritionCategory>(
          value: widget.draft.category,
          items: [
            for (final c in NutritionCategory.values)
              DropdownMenuItem(
                  value: c, child: Text('${c.emoji} ${c.label}'))
          ],
          onChanged: (c) {
            if (c != null) widget.onChanged(widget.draft..category = c);
          },
          underline: const SizedBox(),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: TextFormField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(suffixText: 'g', isDense: true),
            onChanged: (v) =>
                widget.onChanged(widget.draft..amount = double.tryParse(v) ?? 0),
          ),
        ),
        IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            onPressed: widget.onRemove),
      ]),
    );
  }
}
