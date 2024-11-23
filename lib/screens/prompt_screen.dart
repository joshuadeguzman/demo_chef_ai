import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PromptScreen extends StatelessWidget {
  const PromptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'What would you like to cook?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: null,
                ),
              ),
            ),
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.push('/recipe-list'),
                  child: const Text('Generate Recipe'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 