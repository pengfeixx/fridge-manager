import 'package:fridge_manager/domain/ai/food_recognition.dart';
import 'package:fridge_manager/domain/entities/recipe.dart';

/// AI 服务抽象接口。实现可替换为 OpenAI 兼容、自建后端等。
abstract class AiService {
  /// 识别图片中的食材清单。
  Future<List<RecognizedFood>> recognizeFoods(String base64Image);

  /// 从自然语言文本解析食材清单（用于语音转文字后解析）。
  Future<List<RecognizedFood>> parseFoodsFromText(String text);

  /// 根据现有食材生成菜谱。
  Future<Recipe?> generateRecipe(List<String> availableFoods);

  /// 测试连接是否可用。
  Future<bool> testConnection();
}
