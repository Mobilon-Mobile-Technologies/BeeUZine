import 'package:beeuzine/landing_page.dart';
import 'package:beeuzine/login.dart';
import 'package:beeuzine/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://wuzhfgwocobgpoyzwcal.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind1emhmZ3dvY29iZ3BveXp3Y2FsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE4OTExMTgsImV4cCI6MjA1NzQ2NzExOH0.w2BQtfmpSujUQVBR1nseGOCG1-JMLsAB2ibLNHNrBGo',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

// Custom page route for smoother transitions
class FadePageRoute<T> extends PageRoute<T> {
  FadePageRoute({
    required this.builder,
    RouteSettings? settings,
    this.maintainState = true,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.opaque = true,
    this.barrierDismissible = false,
    this.barrierColor,
    this.barrierLabel,
  }) : super(settings: settings, fullscreenDialog: false);

  final WidgetBuilder builder;

  @override
  final Duration transitionDuration;

  @override
  final bool opaque;

  @override
  final bool maintainState;

  @override
  final bool barrierDismissible;

  @override
  final Color? barrierColor;

  @override
  final String? barrierLabel;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if there's a current session
    final session = supabase.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BeeUZine',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFD85B),
        ),
        // Add smooth page transitions
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      // Define named routes for navigation
      routes: {
        '/': (context) => session != null ? const MainPage() : WelcomePage(),
        '/main': (context) => const MainPage(),
        '/login': (context) => LoginPage(),
      },
      // Custom route generator for smoother transitions
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/main':
            return FadePageRoute(
              builder: (_) => const MainPage(),
              settings: settings,
            );
          case '/login':
            return FadePageRoute(
              builder: (_) => LoginPage(),
              settings: settings,
            );
          default:
            return null;
        }
      },
      // If there's a session, go to the main app, otherwise show the welcome page
      initialRoute: '/',
    );
  }
}
