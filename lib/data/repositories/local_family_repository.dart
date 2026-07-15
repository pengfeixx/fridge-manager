import 'package:fridge_manager/data/database/daos/family_member_dao.dart';
import 'package:fridge_manager/domain/entities/family_member.dart';
import 'package:fridge_manager/domain/repositories/family_repository.dart';

class LocalFamilyRepository implements FamilyRepository {
  final FamilyMemberDao _dao;
  const LocalFamilyRepository(this._dao);

  @override
  Stream<List<FamilyMember>> watchAll() => _dao.watchAll();

  @override
  Future<int> add(FamilyMember member) => _dao.add(member);

  @override
  Future<void> update(FamilyMember member) => _dao.updateRow(member);

  @override
  Future<void> delete(int id) => _dao.remove(id);
}
