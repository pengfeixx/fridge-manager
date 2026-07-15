import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/features/fridge/providers/fridge_providers.dart';

final familyMembersProvider = StreamProvider((ref) {
  return ref.watch(familyRepositoryProvider).watchAll();
});
