import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_manager/domain/ai/food_recognition.dart';

/// 拍照识图的中间结果，从 ScanPage 传到 ScanConfirmPage。
final scanResultProvider = StateProvider<List<RecognizedFood>>((ref) => []);
