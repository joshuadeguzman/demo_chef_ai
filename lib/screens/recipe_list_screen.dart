import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/recipe.dart';

class RecipeListScreen extends StatefulWidget {
  final Map<String, dynamic> recipeData;
  
  const RecipeListScreen({
    super.key,
    required this.recipeData,
  });

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  late List<Ingredient> ingredients;
  int selectedCount = 0;

  @override
  void initState() {
    super.initState();
    ingredients = (widget.recipeData['ingredients'] as List)
        .map((item) => Ingredient.fromJson(item))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipeData['recipeName']),
        actions: [
          Chip(
            label: Text('$selectedCount items'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.recipeData['description'],
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.recipeData['totalTime']} minutes',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.recipeData['difficulty'],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const Divider(height: 32),
                Text(
                  'Ingredients',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = ingredients[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: Card(
                    child: Hero(
                      tag: 'ingredient_${ingredient.id}',
                      child: Material(
                        child: CheckboxListTile(
                          title: Text(
                            ingredient.name,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          subtitle: Text(
                            ingredient.quantity,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          value: ingredient.isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              ingredient.isSelected = value ?? false;
                              selectedCount = ingredients
                                  .where((element) => element.isSelected)
                                  .length;
                            });
                          },
                          secondary: Icon(
                            Icons.shopping_basket_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (selectedCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        '$selectedCount ingredients selected',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: selectedCount > 0
                          ? () => context.push('/cooking', extra: widget.recipeData)
                          : null,
                      child: const Text('Start Cooking'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 