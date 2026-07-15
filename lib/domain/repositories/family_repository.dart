import 'package:fridge_manager/domain/entities/family_member.dart';

abstract class FamilyRepository {
  Stream<List<FamilyMember>> watchAll();
  Future<int> add(FamilyMember member);
  Future<void> update(FamilyMember member);
  Future<void> delete(int id);
}
