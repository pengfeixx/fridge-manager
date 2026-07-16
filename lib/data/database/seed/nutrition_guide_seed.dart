import 'package:fridge_manager/domain/entities/nutrition_guide.dart';

/// 基于《中国居民膳食指南(2022)》的简化参考表。
/// 按年龄段(儿童/青少年/成人/老年) × 性别 × 类别，每日推荐克数。
/// 标注: 此为参考值, 实际需求因个体活动量等因素而异。
const kNutritionGuideSeed = <NutritionGuide>[
  // === 2-5 岁 ===
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'male', category: NutritionCategory.grains, dailyGram: 100),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'male', category: NutritionCategory.vegetables, dailyGram: 200),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'male', category: NutritionCategory.fruits, dailyGram: 150),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'male', category: NutritionCategory.protein, dailyGram: 50),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'male', category: NutritionCategory.dairy, dailyGram: 400),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'male', category: NutritionCategory.oilSalt, dailyGram: 25),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'female', category: NutritionCategory.grains, dailyGram: 85),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'female', category: NutritionCategory.vegetables, dailyGram: 200),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'female', category: NutritionCategory.fruits, dailyGram: 150),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'female', category: NutritionCategory.protein, dailyGram: 50),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'female', category: NutritionCategory.dairy, dailyGram: 400),
  NutritionGuide(ageMin: 2, ageMax: 5, gender: 'female', category: NutritionCategory.oilSalt, dailyGram: 25),

  // === 6-17 岁 ===
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'male', category: NutritionCategory.grains, dailyGram: 250),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'male', category: NutritionCategory.vegetables, dailyGram: 400),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'male', category: NutritionCategory.fruits, dailyGram: 250),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'male', category: NutritionCategory.protein, dailyGram: 120),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'male', category: NutritionCategory.dairy, dailyGram: 400),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'male', category: NutritionCategory.oilSalt, dailyGram: 30),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'female', category: NutritionCategory.grains, dailyGram: 225),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'female', category: NutritionCategory.vegetables, dailyGram: 375),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'female', category: NutritionCategory.fruits, dailyGram: 225),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'female', category: NutritionCategory.protein, dailyGram: 110),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'female', category: NutritionCategory.dairy, dailyGram: 400),
  NutritionGuide(ageMin: 6, ageMax: 17, gender: 'female', category: NutritionCategory.oilSalt, dailyGram: 28),

  // === 18-64 岁 ===
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'male', category: NutritionCategory.grains, dailyGram: 300),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'male', category: NutritionCategory.vegetables, dailyGram: 500),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'male', category: NutritionCategory.fruits, dailyGram: 350),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'male', category: NutritionCategory.protein, dailyGram: 175),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'male', category: NutritionCategory.dairy, dailyGram: 400),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'male', category: NutritionCategory.oilSalt, dailyGram: 30),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'female', category: NutritionCategory.grains, dailyGram: 250),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'female', category: NutritionCategory.vegetables, dailyGram: 400),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'female', category: NutritionCategory.fruits, dailyGram: 300),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'female', category: NutritionCategory.protein, dailyGram: 140),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'female', category: NutritionCategory.dairy, dailyGram: 400),
  NutritionGuide(ageMin: 18, ageMax: 64, gender: 'female', category: NutritionCategory.oilSalt, dailyGram: 25),

  // === 65+ 岁 ===
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'male', category: NutritionCategory.grains, dailyGram: 250),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'male', category: NutritionCategory.vegetables, dailyGram: 400),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'male', category: NutritionCategory.fruits, dailyGram: 300),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'male', category: NutritionCategory.protein, dailyGram: 150),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'male', category: NutritionCategory.dairy, dailyGram: 400),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'male', category: NutritionCategory.oilSalt, dailyGram: 25),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'female', category: NutritionCategory.grains, dailyGram: 225),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'female', category: NutritionCategory.vegetables, dailyGram: 350),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'female', category: NutritionCategory.fruits, dailyGram: 275),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'female', category: NutritionCategory.protein, dailyGram: 130),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'female', category: NutritionCategory.dairy, dailyGram: 400),
  NutritionGuide(ageMin: 65, ageMax: 200, gender: 'female', category: NutritionCategory.oilSalt, dailyGram: 22),
];
