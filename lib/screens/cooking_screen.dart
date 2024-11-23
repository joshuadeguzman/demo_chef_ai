import 'package:flutter/material.dart';
import '../models/recipe.dart';
import 'package:go_router/go_router.dart';

class CookingScreen extends StatelessWidget {
  const CookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data - replace with actual recipe steps
    final steps = [
      CookingStep(
        order: 1,
        description: 'Dice the tomatoes and onions',
        duration: const Duration(minutes: 5),
      ),
      CookingStep(
        order: 2,
        description: 'Heat olive oil in a pan',
        duration: const Duration(minutes: 2),
      ),
      CookingStep(
        order: 3,
        description: 'Sauté the onions until translucent',
        duration: const Duration(minutes: 5),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cooking Instructions'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                child: Text('${step.order}'),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '${step.duration.inMinutes} min',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            step.description,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
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
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.push('/feedback'),
                  child: const Text('Finish Cooking'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 