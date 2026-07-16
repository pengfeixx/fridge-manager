import 'package:flutter_test/flutter_test.dart';
import 'package:fridge_manager/domain/ai/food_recognition.dart';

void main() {
  group('FoodRecognitionParser.parse', () {
    test('解析标准 JSON 数组', () {
      const json = '''
      ```json
      [
        {"name": "西红柿", "quantity": 3, "unit": "个"},
        {"name": "鸡蛋", "quantity": 500, "unit": "g"}
      ]
      ```''';
      final result = FoodRecognitionParser.parse(json);
      expect(result, hasLength(2));
      expect(result[0].name, '西红柿');
      expect(result[0].quantity, 3);
      expect(result[0].unit, '个');
      expect(result[1].name, '鸡蛋');
    });

    test('解析无 markdown 包裹的裸 JSON 数组', () {
      const json = '[{"name":"白菜","quantity":1,"unit":"颗"}]';
      final result = FoodRecognitionParser.parse(json);
      expect(result, hasLength(1));
      expect(result[0].name, '白菜');
    });

    test('解析带噪声文本中嵌入的 JSON', () {
      const json = '好的，识别结果如下：\n[{"name":"猪肉","quantity":300,"unit":"g"}]\n以上。';
      final result = FoodRecognitionParser.parse(json);
      expect(result, hasLength(1));
      expect(result[0].name, '猪肉');
    });

    test('缺省 quantity 默认为 1', () {
      const json = '[{"name":"豆腐","unit":"块"}]';
      final result = FoodRecognitionParser.parse(json);
      expect(result[0].quantity, 1);
    });

    test('缺省 unit 默认为 份', () {
      const json = '[{"name":"豆腐"}]';
      final result = FoodRecognitionParser.parse(json);
      expect(result[0].unit, '份');
    });

    test('无效输入返回空列表', () {
      expect(FoodRecognitionParser.parse('这不是JSON'), isEmpty);
      expect(FoodRecognitionParser.parse(''), isEmpty);
    });
  });

  group('RecognizedFood', () {
    test('copyWith 可覆盖部分字段', () {
      const food = RecognizedFood(name: '西红柿', quantity: 3, unit: '个');
      final updated = food.copyWith(quantity: 5);
      expect(updated.name, '西红柿');
      expect(updated.quantity, 5);
      expect(updated.unit, '个');
    });

    test('copyWith 不传参返回等价值', () {
      const food = RecognizedFood(name: '鸡蛋', quantity: 2, unit: '个');
      final copy = food.copyWith();
      expect(copy.name, food.name);
      expect(copy.quantity, food.quantity);
      expect(copy.unit, food.unit);
    });
  });
}
