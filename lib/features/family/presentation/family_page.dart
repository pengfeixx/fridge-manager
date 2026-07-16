import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/family_member.dart';
import 'package:fridge_manager/features/family/presentation/member_edit_page.dart';
import 'package:fridge_manager/features/family/providers/family_providers.dart';
import 'package:fridge_manager/features/fridge/providers/fridge_providers.dart';

class FamilyPage extends ConsumerWidget {
  const FamilyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMembers = ref.watch(familyMembersProvider);
    final repo = ref.watch(familyRepositoryProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('家庭成员')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('添加成员'),
        onPressed: () async {
          final m = await showMemberEditPage(context, null);
          if (m != null) await repo.add(m);
        },
      ),
      body: asyncMembers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('出错：$e')),
        data: (members) {
          if (members.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.family_restroom_rounded,
                        size: 80, color: scheme.outline),
                    const SizedBox(height: 16),
                    Text('还没有家庭成员',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Text('添加家庭成员后，菜谱推荐会自动避开忌口和过敏食材',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 14, color: scheme.outline)),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: members.length,
            itemBuilder: (_, i) {
              final m = members[i];
              return _MemberCard(
                member: m,
                onTap: () async {
                  final edited = await showMemberEditPage(context, m);
                  if (edited != null) await repo.update(edited);
                },
                onDelete: () => _confirmDelete(context, ref, m),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, FamilyMember m) async {
    final scheme = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除成员？'),
        content: Text('确定要删除 ${m.name} 吗？此操作不可撤销。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消')),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('删除')),
        ],
      ),
    );
    if (ok == true && m.id != null) {
      await ref.read(familyRepositoryProvider).delete(m.id!);
    }
  }
}

class _MemberCard extends StatelessWidget {
  final FamilyMember member;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _MemberCard(
      {required this.member, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isMale = member.gender == Gender.male;
    final avatarColor =
        isMale ? const Color(0xFFBBDEFB) : const Color(0xFFF8BBD0);
    final avatarFg =
        isMale ? const Color(0xFF0D47A1) : const Color(0xFF880E4F);
    final hasRestrictions =
        member.dietaryTags.isNotEmpty || member.allergies.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: avatarColor,
                  child: Icon(
                    isMale ? Icons.male_rounded : Icons.female_rounded,
                    color: avatarFg,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              member.name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${member.age}岁',
                              style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (hasRestrictions) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            for (final t in member.dietaryTags)
                              _RestrictionTag(
                                label: t,
                                bgColor: scheme.tertiaryContainer,
                                fgColor: scheme.onTertiaryContainer,
                              ),
                            for (final a in member.allergies)
                              _RestrictionTag(
                                label: '过敏:$a',
                                bgColor: scheme.errorContainer,
                                fgColor: scheme.onErrorContainer,
                              ),
                          ],
                        ),
                      ] else ...[
                        const SizedBox(height: 4),
                        Text('无忌口',
                            style: TextStyle(
                                fontSize: 13, color: scheme.outline)),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded,
                      size: 20, color: scheme.outline),
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RestrictionTag extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color fgColor;
  const _RestrictionTag(
      {required this.label, required this.bgColor, required this.fgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: fgColor),
      ),
    );
  }
}
