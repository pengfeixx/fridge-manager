import 'package:flutter_test/flutter_test.dart';
import 'package:fridge_manager/domain/entities/enums.dart';
import 'package:fridge_manager/domain/entities/family_member.dart';
import 'package:fridge_manager/domain/entities/food_item.dart';
import 'package:fridge_manager/domain/entities/recipe.dart';
import 'package:fridge_manager/domain/services/recommendation_service.dart';

FoodItem _f(String name, {int daysAgo = 0, int shelf = 7}) => FoodItem(
    name: name, categoryId: 1, quantity: 1, unit: '份',
    storage: Storage.chilled,
    addedDate: DateTime(2026, 7, 15).subtract(Duration(days: daysAgo)),
    shelfLifeDays: shelf);

final now = DateTime(2026, 7, 15);

void main() {
  final recipes = [
    const Recipe(title: '西红柿炒蛋', ingredients: [
      RecipeIngredient(foodName: '西红柿', amount: 2, unit: '个'),
      RecipeIngredient(foodName: '鸡蛋', amount: 3, unit: '个'),
    ]),
    const Recipe(title: '土豆炖牛肉', ingredients: [
      RecipeIngredient(foodName: '土豆', amount: 1, unit: '个'),
      RecipeIngredient(foodName: '牛肉', amount: 300, unit: 'g'),
    ]),
  ];

  test('有全部食材的菜谱得分更高', () {
    final stock = [_f('西红柿'), _f('鸡蛋'), _f('土豆')]; // 牛肉没有
    final scored = RecommendationService.recommend(recipes, stock, [], now);
    expect(scored.first.recipe.title, '西红柿炒蛋');
    expect(scored.first.coverage, greaterThan(scored.last.coverage));
  });

  test('临近过期的食材匹配的菜谱额外加权', () {
    final fresh = [_f('西红柿', daysAgo: 0), _f('鸡蛋', daysAgo: 0)];
    final near = [_f('西红柿', daysAgo: 6, shelf: 7), _f('鸡蛋', daysAgo: 6, shelf: 7)];
    final sFresh = RecommendationService.recommend(recipes, fresh, [], now);
    final sNear = RecommendationService.recommend(recipes, near, [], now);
    // 同样全覆盖，临期组合分数应更高
    expect(sNear.first.score, greaterThan(sFresh.first.score));
  });

  test('任一成员忌口命中菜谱标签则过滤', () {
    const member = FamilyMember(name: '爸', age: 50, dietaryTags: ['不吃辣']);
    const spicy = Recipe(
      title: '辣椒炒肉', tags: ['辣'],
      ingredients: [RecipeIngredient(foodName: '辣椒', amount: 1, unit: '个')],
    );
    final scored = RecommendationService.recommend([spicy], [_f('辣椒')], [member], now);
    expect(scored, isEmpty);
  });

  test('成员过敏原命中菜谱食材则过滤', () {
    const member = FamilyMember(name: '娃', age: 8, allergies: ['鸡蛋']);
    final scored = RecommendationService.recommend(recipes, [_f('西红柿'), _f('鸡蛋')], [member], now);
    expect(scored.map((s) => s.recipe.title), isNot(contains('西红柿炒蛋')));
  });
}
