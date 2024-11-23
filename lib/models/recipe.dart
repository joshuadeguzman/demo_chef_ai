class Recipe {
  final String id;
  final String name;
  final String description;
  final List<Ingredient> ingredients;
  final List<CookingStep> steps;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.steps,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ingredients: (json['ingredients'] as List)
          .map((i) => Ingredient.fromJson(i))
          .toList(),
      steps: (json['steps'] as List)
          .map((s) => CookingStep.fromJson(s))
          .toList(),
    );
  }
}

class Ingredient {
  final String id;
  final String name;
  final String quantity;
  bool isSelected;

  Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
    this.isSelected = false,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
    );
  }
}

class CookingStep {
  final int order;
  final String description;
  final Duration duration;

  CookingStep({
    required this.order,
    required this.description,
    required this.duration,
  });

  factory CookingStep.fromJson(Map<String, dynamic> json) {
    return CookingStep(
      order: json['order'],
      description: json['description'],
      duration: Duration(minutes: json['duration_minutes'] ?? 0),
    );
  }
} 