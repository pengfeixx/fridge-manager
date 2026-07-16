import 'package:flutter/material.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/family_member.dart';

/// 弹出成员编辑面板，返回填写好的 FamilyMember；返回 null 表示取消。
Future<FamilyMember?> showMemberEditPage(
    BuildContext context, FamilyMember? existing) {
  return showModalBottomSheet<FamilyMember>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _MemberEditSheet(existing: existing),
  );
}

class _MemberEditSheet extends StatefulWidget {
  final FamilyMember? existing;
  const _MemberEditSheet({this.existing});

  @override
  State<_MemberEditSheet> createState() => _MemberEditSheetState();
}

class _MemberEditSheetState extends State<_MemberEditSheet> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _age = TextEditingController(
      text: (widget.existing != null && widget.existing!.age > 0)
          ? widget.existing!.age.toString()
          : '');
  late Gender _gender = widget.existing?.gender ?? Gender.male;

  /// 忌口列表：合并预设与已有自定义项，去重。
  final _dietaryTags = <String>[];
  final _allergies = <String>[];

  static const _dietPresets = ['不吃辣', '素食', '清真', '不吃海鲜', '不吃牛羊肉'];
  static const _allergyPresets = ['花生', '海鲜', '鸡蛋', '牛奶', '麸质'];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _dietaryTags.addAll(widget.existing!.dietaryTags);
      _allergies.addAll(widget.existing!.allergies);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
              child: Row(
                children: [
                  Text(
                    widget.existing == null ? '添加家庭成员' : '编辑成员',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                children: [
                  // 姓名 + 年龄
                  Row(children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _name,
                        autofocus: widget.existing == null,
                        decoration: const InputDecoration(
                          labelText: '姓名',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _age,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '年龄'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // 性别
                  _SectionLabel(text: '性别'),
                  const SizedBox(height: 8),
                  SegmentedButton<Gender>(
                    segments: const [
                      ButtonSegment(
                          value: Gender.male,
                          icon: Icon(Icons.male_rounded, size: 18),
                          label: Text('男')),
                      ButtonSegment(
                          value: Gender.female,
                          icon: Icon(Icons.female_rounded, size: 18),
                          label: Text('女')),
                    ],
                    selected: {_gender},
                    onSelectionChanged: (s) => setState(() => _gender = s.first),
                  ),
                  const SizedBox(height: 20),

                  // 忌口
                  _TagEditor(
                    label: '忌口',
                    icon: Icons.restaurant_menu_rounded,
                    presets: _dietPresets,
                    selected: _dietaryTags,
                    hint: '输入自定义忌口，如"不吃香菜"',
                    scheme: scheme,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 20),

                  // 过敏
                  _TagEditor(
                    label: '过敏原',
                    icon: Icons.warning_amber_rounded,
                    presets: _allergyPresets,
                    selected: _allergies,
                    hint: '输入过敏食材，如"芒果"',
                    scheme: scheme,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded),
                label: Text(widget.existing == null ? '添加' : '保存修改'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入姓名')),
      );
      return;
    }
    Navigator.pop(
      context,
      FamilyMember(
        id: widget.existing?.id,
        name: name,
        age: int.tryParse(_age.text) ?? 0,
        gender: _gender,
        dietaryTags: List.from(_dietaryTags),
        allergies: List.from(_allergies),
      ),
    );
  }
}

/// 标签编辑器：预设 Chip + 自定义输入框 + 已选标签列表（可删除）。
class _TagEditor extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<String> presets;
  final List<String> selected;
  final String hint;
  final ColorScheme scheme;
  final VoidCallback onChanged;

  const _TagEditor({
    required this.label,
    required this.icon,
    required this.presets,
    required this.selected,
    required this.hint,
    required this.scheme,
    required this.onChanged,
  });

  @override
  State<_TagEditor> createState() => _TagEditorState();
}

class _TagEditorState extends State<_TagEditor> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _showAdd = false;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool _isSelected(String s) => widget.selected.contains(s);

  void _togglePreset(String s) {
    if (_isSelected(s)) {
      widget.selected.remove(s);
    } else {
      widget.selected.add(s);
    }
    widget.onChanged();
  }

  void _addCustom() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !_isSelected(text)) {
      widget.selected.add(text);
      _controller.clear();
      widget.onChanged();
    }
    setState(() => _showAdd = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = widget.scheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(text: widget.label, icon: widget.icon),
        const SizedBox(height: 8),
        // 已选标签（含自定义），可点击删除
        if (widget.selected.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final tag in widget.selected)
                GestureDetector(
                  onTap: () {
                    widget.selected.remove(tag);
                    widget.onChanged();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: widget.label == '忌口'
                          ? scheme.tertiaryContainer
                          : scheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label == '过敏原' ? '过敏:$tag' : tag,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: widget.label == '忌口'
                                ? scheme.onTertiaryContainer
                                : scheme.onErrorContainer,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.close_rounded, size: 14),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        // 预设选项
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (final p in widget.presets)
              FilterChip(
                label: Text(p),
                selected: _isSelected(p),
                onSelected: (_) => _togglePreset(p),
                visualDensity: VisualDensity.compact,
              ),
            // 自定义添加按钮
            ActionChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 16),
                  const SizedBox(width: 2),
                  const Text('自定义'),
                ],
              ),
              onPressed: () => setState(() {
                _showAdd = true;
                _focus.requestFocus();
              }),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        // 自定义输入框
        if (_showAdd) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            focusNode: _focus,
            decoration: InputDecoration(
              hintText: widget.hint,
              isDense: true,
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle_rounded),
                onPressed: _addCustom,
              ),
            ),
            onSubmitted: (_) => _addCustom(),
          ),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final IconData? icon;
  const _SectionLabel({required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      if (icon != null)
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(icon,
              size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.3,
        ),
      ),
    ]);
  }
}
