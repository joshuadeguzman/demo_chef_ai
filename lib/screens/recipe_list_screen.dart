import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/recipe.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final List<Ingredient> ingredients = [
    // Dummy data - replace with actual API data
    Ingredient(id: '1', name: 'Tomatoes', quantity: '2 pieces'),
    Ingredient(id: '2', name: 'Onions', quantity: '1 medium'),
    Ingredient(id: '3', name: 'Olive Oil', quantity: '2 tbsp'),
  ];

  int selectedCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients'),
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
          Expanded(
            child: ListView.builder(
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = ingredients[index];
                return Hero(
                  tag: 'ingredient_${ingredient.id}',
                  child: Material(
                    child: CheckboxListTile(
                      title: Text(ingredient.name),
                      subtitle: Text(ingredient.quantity),
                      value: ingredient.isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          ingredient.isSelected = value ?? false;
                          selectedCount = ingredients
                              .where((element) => element.isSelected)
                              .length;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: selectedCount > 0
                      ? () => context.push('/cooking')
                      : null,
                  child: const Text('Start Cooking'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 