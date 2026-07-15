// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_member_dao.dart';

// ignore_for_file: type=lint
mixin _$FamilyMemberDaoMixin on DatabaseAccessor<AppDatabase> {
  $FamilyMembersTable get familyMembers => attachedDatabase.familyMembers;
  FamilyMemberDaoManager get managers => FamilyMemberDaoManager(this);
}

class FamilyMemberDaoManager {
  final _$FamilyMemberDaoMixin _db;
  FamilyMemberDaoManager(this._db);
  $$FamilyMembersTableTableManager get familyMembers =>
      $$FamilyMembersTableTableManager(_db.attachedDatabase, _db.familyMembers);
}
