enum Storage {
  chilled('冷藏'),
  frozen('冷冻'),
  room('常温');

  final String label;
  const Storage(this.label);

  static Storage parse(String raw) {
    return switch (raw) {
      '冷藏' || 'chilled' => Storage.chilled,
      '冷冻' || 'frozen' => Storage.frozen,
      '常温' || 'room' => Storage.room,
      _ => Storage.chilled,
    };
  }
}

enum FoodStatus { inStock, used, discarded }

enum Gender { male, female, other }

enum MealType { breakfast, lunch, dinner, snack }

enum RecipeSource { local, ai }
