import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fridge_manager/domain/entities/food_item.dart';
import 'package:fridge_manager/features/family/presentation/family_page.dart';
import 'package:fridge_manager/features/fridge/presentation/add_food_page.dart';
import 'package:fridge_manager/features/fridge/presentation/fridge_page.dart';
import 'package:fridge_manager/features/nutrition/presentation/nutrition_page.dart';
import 'package:fridge_manager/features/nutrition/presentation/shopping_suggestion_page.dart';
import 'package:fridge_manager/features/recipes/presentation/recipe_detail_page.dart';
import 'package:fridge_manager/features/recipes/presentation/recipes_page.dart';
import 'package:fridge_manager/features/scan/presentation/scan_confirm_page.dart';
import 'package:fridge_manager/features/scan/presentation/scan_page.dart';
import 'package:fridge_manager/features/settings/presentation/settings_page.dart';
import 'package:fridge_manager/features/voice/presentation/voice_input_page.dart';

final _rootNavKey = GlobalKey<NavigatorState>();
final _fridgeKey = GlobalKey<NavigatorState>(debugLabel: 'fridge');
final _recipesKey = GlobalKey<NavigatorState>(debugLabel: 'recipes');
final _familyKey = GlobalKey<NavigatorState>(debugLabel: 'family');
final _nutritionKey = GlobalKey<NavigatorState>(debugLabel: 'nutrition');

final appRouter = GoRouter(
  navigatorKey: _rootNavKey,
  initialLocation: '/fridge',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) =>
          RootScaffold(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          navigatorKey: _fridgeKey,
          routes: [
            GoRoute(
              path: '/fridge',
              builder: (_, __) => const FridgePage(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (_, s) =>
                      AddFoodPage(editingItem: s.extra as FoodItem?),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _recipesKey,
          routes: [
            GoRoute(
              path: '/recipes',
              builder: (_, __) => const RecipesPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, s) =>
                      RecipeDetailPage(id: int.parse(s.pathParameters['id']!)),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _familyKey,
          routes: [
            GoRoute(
              path: '/family',
              builder: (_, __) => const FamilyPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _nutritionKey,
          routes: [
            GoRoute(
              path: '/nutrition',
              builder: (_, __) => const NutritionPage(),
              routes: [
                GoRoute(
                  path: 'shopping',
                  builder: (_, __) => const ShoppingSuggestionPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (_, __) => const SettingsPage(),
    ),
    GoRoute(
      path: '/scan',
      builder: (_, __) => const ScanPage(),
      routes: [
        GoRoute(
          path: 'confirm',
          builder: (_, __) => const ScanConfirmPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/voice',
      builder: (_, __) => const VoiceInputPage(),
    ),
  ],
);

class RootScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const RootScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.kitchen), label: '冰箱'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: '菜谱'),
          NavigationDestination(icon: Icon(Icons.family_restroom), label: '家庭'),
          NavigationDestination(
              icon: Icon(Icons.restaurant_rounded), label: '营养'),
        ],
      ),
    );
  }
}
