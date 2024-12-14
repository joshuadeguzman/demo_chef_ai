import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
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

  late FirebaseRemoteConfig remoteConfig;

  bool isRecommenderEnabled = false;

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

    _loadFirebaseConfig();

    super.initState();
  }

  Future<void> _loadFirebaseConfig() async {
    remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setDefaults(
      const {"is_recommender_enabled": false},
    );
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(minutes: 1),
    ));
    await remoteConfig.fetchAndActivate();

    final isRecommenderEnabled = remoteConfig.getBool('is_recommender_enabled');

    setState(() {
      this.isRecommenderEnabled = isRecommenderEnabled == true;
    });
  }

  Future<void> _generateRecipe() async {
    setState(() {
      _isLoading = true;
    });

    // TODO(joshua): Copy the prompt from prompt.txt and paste it here.

    try {
      // TODO(steps): Call the model and get the response.

      // TODO(steps): Parse the response and push to the cooking screen.
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'What would you\nlike to cook?',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'I\'ll help you with the recipe and instructions',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _promptController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Spaghetti Carbonara',
                    hintStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.4),
                    ),
                    prefixIcon: Icon(
                      Icons.restaurant_menu,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isLoading ? null : _generateRecipe,
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : isRecommenderEnabled
                          ? const Text(
                              'Surprise Me!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : const Text(
                              'Generate Recipe',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
