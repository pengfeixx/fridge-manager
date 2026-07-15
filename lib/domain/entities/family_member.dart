import 'package:fridge_manager/domain/entities/enums.dart';

class FamilyMember {
  final int? id;
  final String name;
  final int age;
  final Gender gender;
  final List<String> dietaryTags;
  final List<String> allergies;

  const FamilyMember({
    this.id,
    required this.name,
    required this.age,
    this.gender = Gender.other,
    this.dietaryTags = const [],
    this.allergies = const [],
  });

  FamilyMember copyWith({
    int? id,
    String? name,
    int? age,
    Gender? gender,
    List<String>? dietaryTags,
    List<String>? allergies,
  }) =>
      FamilyMember(
        id: id ?? this.id,
        name: name ?? this.name,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        dietaryTags: dietaryTags ?? this.dietaryTags,
        allergies: allergies ?? this.allergies,
      );
}
