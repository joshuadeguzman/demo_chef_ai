import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CookingScreen extends StatefulWidget {
  final Map<String, dynamic> recipeData;

  const CookingScreen({
    super.key,
    required this.recipeData,
  });

  @override
  State<CookingScreen> createState() => _CookingScreenState();
}

class _CookingScreenState extends State<CookingScreen> {
  late PageController _pageController;
  int _currentStep = 0;
  List<dynamic> steps = [];
  bool _showIngredients = false;
  final Map<int, bool> _completedSteps = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    steps = widget.recipeData['steps'] as List;
    // Initialize all steps as incomplete
    for (var i = 0; i < steps.length; i++) {
      _completedSteps[i] = false;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _markStepComplete(int index) {
    setState(() {
      _completedSteps[index] = true;
    });
  }

  bool _canProceedToNext() {
    return _completedSteps[_currentStep] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final totalTimeMinutes = widget.recipeData['totalTime'];
    final difficulty = widget.recipeData['difficulty'];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.recipeData['recipeName']),
            Text(
              '${_currentStep + 1} of ${steps.length} steps',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$totalTimeMinutes min',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      difficulty,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              LinearProgressIndicator(
                value: (_currentStep + 1) / steps.length,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showIngredients ? Icons.restaurant : Icons.list,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              setState(() {
                _showIngredients = !_showIngredients;
              });
            },
          ),
        ],
      ),
      body: _showIngredients ? _buildIngredientsView() : _buildStepsView(),
    );
  }

  Widget _buildStepCard(Map<String, dynamic> step, int index) {
    final duration = step['duration_minutes'];
    final equipment = step['equipment'] as List?;
    final tips = step['tips'] as String?;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _completedSteps[index] == true
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceVariant,
                  child: _completedSteps[index] == true
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.onPrimary,
                        )
                      : Text(
                          '${step['order']}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                if (duration != null)
                  Chip(
                    avatar: const Icon(Icons.timer_outlined, size: 16),
                    label: Text('$duration min'),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              step['description'],
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (equipment != null && equipment.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Equipment needed:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: equipment
                    .map((e) => Chip(
                          label: Text(e),
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceVariant,
                        ))
                    .toList(),
              ),
            ],
            if (tips != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tips,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (!_completedSteps[index]!)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _markStepComplete(index),
                  icon: const Icon(Icons.check),
                  label: const Text('Mark as Complete'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsView() {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentStep = index;
              });
            },
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _currentStep == index ? 1.0 : 0.5,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildStepCard(step, index),
                      const SizedBox(height: 16),
                      if (index < steps.length - 1)
                        TextButton.icon(
                          onPressed: _canProceedToNext()
                              ? () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              : null,
                          icon: const Text('Swipe for next step'),
                          label: const Icon(Icons.arrow_forward),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _canProceedToNext()
                        ? () {
                            if (_currentStep < steps.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              context.push('/feedback');
                            }
                          }
                        : null,
                    icon: Text(_currentStep < steps.length - 1 ? 'Next' : 'Finish'),
                    label: Icon(
                      _currentStep < steps.length - 1
                          ? Icons.arrow_forward
                          : Icons.check_circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsView() {
    final ingredients = widget.recipeData['ingredients'] as List;
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surfaceVariant,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.info_outline),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Keep these ingredients ready for the next steps',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = ingredients[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(ingredient['name']),
                  subtitle: Text(ingredient['quantity']),
                ),
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton(
              onPressed: () {
                setState(() {
                  _showIngredients = false;
                });
              },
              child: const Text('Return to Steps'),
            ),
          ),
        ),
      ],
    );
  }
}
