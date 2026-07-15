import 'package:drift/drift.dart';
import 'package:fridge_manager/data/database/app_database.dart';
import 'package:fridge_manager/data/database/tables.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/family_member.dart';

part 'family_member_dao.g.dart';

@DriftAccessor(tables: [FamilyMembers])
class FamilyMemberDao extends DatabaseAccessor<AppDatabase>
    with _$FamilyMemberDaoMixin {
  FamilyMemberDao(super.db);

  Stream<List<FamilyMember>> watchAll() => select(familyMembers)
      .map((r) => FamilyMember(
            id: r.id,
            name: r.name,
            age: r.age,
            gender: Gender.values.firstWhere(
              (g) => g.name == r.gender,
              orElse: () => Gender.other,
            ),
            dietaryTags: r.dietaryTags.isEmpty ? [] : r.dietaryTags.split(','),
            allergies: r.allergies.isEmpty ? [] : r.allergies.split(','),
          ))
      .watch();

  Future<int> add(FamilyMember m) => into(familyMembers).insert(
        FamilyMembersCompanion.insert(
          name: m.name,
          age: m.age,
          gender: Value(m.gender.name),
          dietaryTags: Value(m.dietaryTags.join(',')),
          allergies: Value(m.allergies.join(',')),
        ),
      );

  Future<int> updateRow(FamilyMember m) =>
      (update(familyMembers)..where((t) => t.id.equals(m.id!))).write(
        FamilyMembersCompanion(
          name: Value(m.name),
          age: Value(m.age),
          gender: Value(m.gender.name),
          dietaryTags: Value(m.dietaryTags.join(',')),
          allergies: Value(m.allergies.join(',')),
        ),
      );

  Future<int> remove(int id) =>
      (delete(familyMembers)..where((t) => t.id.equals(id))).go();
}
