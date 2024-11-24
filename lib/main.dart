import 'package:chef_ai/firebase_options.dart';
import 'package:chef_ai/screens/congratulations_screen.dart';
import 'package:chef_ai/screens/feedback_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/prompt_screen.dart';
import 'screens/recipe_list_screen.dart';
import 'screens/cooking_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Recipe Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          primary: Colors.black,
          background: Colors.white,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PromptScreen(),
    ),
    GoRoute(
      path: '/recipe-list',
      builder: (context, state) => RecipeListScreen(
        recipeData: state.extra as Map<String, dynamic>,
      ),
    ),
    GoRoute(
      path: '/cooking',
      builder: (context, state) => CookingScreen(
        recipeData: state.extra as Map<String, dynamic>,
      ),
    ),
    // ... existing routes ...
    GoRoute(
      path: '/feedback',
      builder: (context, state) => const FeedbackScreen(),
    ),
    GoRoute(
      path: '/congratulations',
      builder: (context, state) => const CongratulationsScreen(),
    ),
  ],
);
