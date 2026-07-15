import 'package:flutter/material.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/family_member.dart';

/// 返回填写好的 FamilyMember（用户确认）；返回 null 表示取消。
Future<FamilyMember?> showMemberEditPage(
    BuildContext context, FamilyMember? existing) {
  return showDialog<FamilyMember>(
    context: context,
    builder: (_) => _MemberEditDialog(existing: existing),
  );
}

class _MemberEditDialog extends StatefulWidget {
  final FamilyMember? existing;
  const _MemberEditDialog({this.existing});

  @override
  State<_MemberEditDialog> createState() => _MemberEditDialogState();
}

class _MemberEditDialogState extends State<_MemberEditDialog> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _age = TextEditingController(
      text: widget.existing?.age.toString() ?? '');
  late Gender _gender = widget.existing?.gender ?? Gender.other;
  late final _diet = TextEditingController(
      text: widget.existing?.dietaryTags.join(',') ?? '');
  late final _allergy = TextEditingController(
      text: widget.existing?.allergies.join(',') ?? '');

  static const _dietOptions = ['不吃辣', '素食', '清真', '不吃海鲜'];
  static const _allergyOptions = ['花生', '海鲜', '麸质', '鸡蛋', '牛奶'];

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _diet.dispose();
    _allergy.dispose();
    super.dispose();
  }

  String _genderLabel(Gender g) =>
      g == Gender.male ? '男' : g == Gender.female ? '女' : '其他';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? '添加成员' : '编辑成员'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: '姓名'),
          ),
          TextField(
            controller: _age,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '年龄'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final g in Gender.values)
                ChoiceChip(
                  label: Text(_genderLabel(g)),
                  selected: _gender == g,
                  onSelected: (_) => setState(() => _gender = g),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final d in _dietOptions)
                FilterChip(
                  label: Text(d),
                  selected: _diet.text.split(',').contains(d),
                  onSelected: (sel) => _toggle(_diet, d, sel),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final a in _allergyOptions)
                FilterChip(
                  label: Text(a),
                  selected: _allergy.text.split(',').contains(a),
                  onSelected: (sel) => _toggle(_allergy, a, sel),
                ),
            ],
          ),
        ]),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(
              context,
              FamilyMember(
                id: widget.existing?.id,
                name: _name.text.trim(),
                age: int.tryParse(_age.text) ?? 0,
                gender: _gender,
                dietaryTags: _split(_diet.text),
                allergies: _split(_allergy.text),
              ),
            );
          },
          child: const Text('保存'),
        ),
      ],
    );
  }

  void _toggle(TextEditingController c, String value, bool sel) {
    final list = _split(c.text);
    if (sel) {
      list.add(value);
    } else {
      list.remove(value);
    }
    c.text = list.join(',');
    setState(() {});
  }

  List<String> _split(String s) =>
      s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
}
