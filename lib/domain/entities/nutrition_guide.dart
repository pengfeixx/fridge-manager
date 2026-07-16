/// 6 大食物类别。
enum NutritionCategory {
  grains('谷薯类', '🍚'),
  vegetables('蔬菜类', '🥬'),
  fruits('水果类', '🍎'),
  protein('畜禽鱼蛋类', '🥩'),
  dairy('奶类及豆制品', '🥛'),
  oilSalt('油盐类', '🧂');

  final String label;
  final String emoji;
  const NutritionCategory(this.label, this.emoji);
}

/// 膳食指南参考条目：某年龄段 × 性别 × 类别 → 每日推荐克数。
class NutritionGuide {
  final int ageMin;
  final int ageMax;
  final String gender; // 'male' / 'female'
  final NutritionCategory category;
  final int dailyGram; // 每日推荐克数（克/天）

  const NutritionGuide({
    required this.ageMin,
    required this.ageMax,
    required this.gender,
    required this.category,
    required this.dailyGram,
  });
}
