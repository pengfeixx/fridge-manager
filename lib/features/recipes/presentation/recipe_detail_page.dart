import 'package:flutter/material.dart';

class RecipeDetailPage extends StatelessWidget {
  final int id;
  const RecipeDetailPage({super.key, required this.id});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('菜谱详情 #$id')));
}
