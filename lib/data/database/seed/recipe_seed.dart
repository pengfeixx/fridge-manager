import 'package:fridge_manager/domain/entities/recipe.dart';

const List<Recipe> kRecipeSeed = [
  Recipe(
    title: '西红柿炒鸡蛋',
    tags: ['家常', '快手'],
    steps: [
      '鸡蛋打散加少许盐，西红柿切块。',
      '热油下蛋液炒散盛出。',
      '底油炒西红柿出汁，加盐糖调味。',
      '倒回鸡蛋翻炒均匀出锅。',
    ],
    ingredients: [
      RecipeIngredient(foodName: '西红柿', amount: 2, unit: '个'),
      RecipeIngredient(foodName: '鸡蛋', amount: 3, unit: '个'),
    ],
  ),
  Recipe(
    title: '土豆炖牛肉',
    tags: ['炖菜'],
    steps: [
      '牛肉切块焯水。',
      '热锅爆香葱姜，下牛肉煸炒。',
      '加水没过牛肉，小火炖 40 分钟。',
      '加土豆块继续炖 15 分钟，盐调味。',
    ],
    ingredients: [
      RecipeIngredient(foodName: '土豆', amount: 2, unit: '个'),
      RecipeIngredient(foodName: '牛肉', amount: 400, unit: 'g'),
    ],
  ),
  Recipe(
    title: '白菜豆腐汤',
    tags: ['汤', '清淡'],
    steps: [
      '白菜切段，豆腐切块。',
      '水烧开下白菜煮软。',
      '加豆腐煮 5 分钟，盐香油调味。',
    ],
    ingredients: [
      RecipeIngredient(foodName: '白菜', amount: 300, unit: 'g'),
      RecipeIngredient(foodName: '豆腐', amount: 1, unit: '块'),
    ],
  ),
  Recipe(
    title: '清炒西兰花',
    tags: ['素菜', '快手'],
    steps: [
      '西兰花掰小朵焯水。',
      '热油蒜末爆香，下西兰花翻炒。',
      '加盐少许水略焖出锅。',
    ],
    ingredients: [
      RecipeIngredient(foodName: '西兰花', amount: 1, unit: '个'),
    ],
  ),
  Recipe(
    title: '胡萝卜炒肉丝',
    tags: ['家常'],
    steps: [
      '猪肉切丝加酱油淀粉抓匀。',
      '胡萝卜切丝。',
      '热油炒肉丝变色盛出。',
      '炒胡萝卜至软，倒回肉丝，盐调味。',
    ],
    ingredients: [
      RecipeIngredient(foodName: '胡萝卜', amount: 1, unit: '根'),
      RecipeIngredient(foodName: '猪肉', amount: 150, unit: 'g'),
    ],
  ),
];
