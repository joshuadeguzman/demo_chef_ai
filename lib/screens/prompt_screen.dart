import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

class PromptScreen extends StatefulWidget {
  const PromptScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PromptScreenState();
  }
}

class _PromptScreenState extends State<PromptScreen> {
  late final GenerativeModel _model;
  late final TextEditingController _promptController;
  late bool _isLoading = false;

  @override
  void initState() {
    var vertexInstance = FirebaseVertexAI.instanceFor(
      auth: FirebaseAuth.instance,
    );

    _model = vertexInstance.generativeModel(
      model: 'gemini-1.5-flash',
    );

    _promptController = TextEditingController();

    _isLoading = false;

    super.initState();
  }

  Future<void> _generateRecipe() async {
    setState(() {
      _isLoading = true;
    });

    final content = [
      Content.multi([
        TextPart(
          '''You are an expert chef. I am a beginner cook. Please provide me the recipe for ${_promptController.text}. 
          Return the response in this exact JSON format:
          {
            "recipeName": "Name of the dish",
            "description": "Brief description of the dish",
            "ingredients": [
              {
                "id": "1",
                "name": "Ingredient name",
                "quantity": "Required quantity"
              }
            ],
            "steps": [
              {
                "order": 1,
                "description": "Detailed step description",
                "duration_minutes": 5
              }
            ],
            "totalTime": "Total cooking time in minutes",
            "difficulty": "easy/medium/hard"
          }''',
        ),
      ]),
    ];

    try {
      var response = await _model.generateContent(content);

      if (response.text == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
          ),
        );
        return;
      }

      debugPrint('Response is ${response.text}');

      final jsonResponse = jsonDecode(
          response.text!.replaceAll('```json', '').replaceAll('```', ''));

      if (mounted) {
        context.push('/recipe-list', extra: jsonResponse);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What would you like to cook?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'I\'ll help you with the recipe and instructions',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _promptController,
                decoration: InputDecoration(
                  hintText: 'e.g., Spaghetti Carbonara',
                  prefixIcon: const Icon(Icons.restaurant_menu),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) => _generateRecipe(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _generateRecipe,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Generate Recipe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
