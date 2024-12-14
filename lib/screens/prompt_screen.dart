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
  String? responseText;
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
      responseText = null;
      _isLoading = true;
    });

    final content = [
      Content.multi([TextPart(_promptController.text)]),
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

      setState(() {
        responseText = response.text;
      });
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
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'Ask Vertex AI anything\nyou want..',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w800,
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
                          hintText: 'Who is Albert Einstein?',
                          hintStyle: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.4),
                          ),
                          prefixIcon: Icon(
                            Icons.chat,
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
                    const SizedBox(height: 12),
                    if (responseText != null)
                      Text(
                        responseText!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    const SizedBox(height: 56),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
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
                                'Send',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
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
