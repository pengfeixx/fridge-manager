import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/features/family/presentation/member_edit_page.dart';
import 'package:fridge_manager/features/family/providers/family_providers.dart';
import 'package:fridge_manager/features/fridge/providers/fridge_providers.dart';

class FamilyPage extends ConsumerWidget {
  const FamilyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMembers = ref.watch(familyMembersProvider);
    final repo = ref.watch(familyRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('家庭成员')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final m = await showMemberEditPage(context, null);
          if (m != null) await repo.add(m);
        },
        child: const Icon(Icons.add),
      ),
      body: asyncMembers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('出错：$e')),
        data: (members) {
          if (members.isEmpty) {
            return const Center(child: Text('还没有家庭成员，点右下角添加'));
          }
          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (_, i) {
              final m = members[i];
              final tags = [...m.dietaryTags, ...m.allergies.map((a) => '过敏:$a')];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text('${m.name}  ${m.age}岁'),
                subtitle: Text(tags.isEmpty ? '无忌口' : tags.join(' · ')),
                onTap: () async {
                  final edited = await showMemberEditPage(context, m);
                  if (edited != null) await repo.update(edited);
                },
                onLongPress: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('删除成员？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('取消'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('删除'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true && m.id != null) await repo.delete(m.id!);
                },
              );
            },
          );
        },
      ),
    );
  }
}
