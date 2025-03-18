import 'package:beeuzine/profile_page.dart';
import 'package:beeuzine/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://wuzhfgwocobgpoyzwcal.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind1emhmZ3dvY29iZ3BveXp3Y2FsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE4OTExMTgsImV4cCI6MjA1NzQ2NzExOH0.w2BQtfmpSujUQVBR1nseGOCG1-JMLsAB2ibLNHNrBGo',
  );
  runApp(MyApp());
}

final supabase = Supabase.instance.client;
final session = supabase.auth.currentUser;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AdminPage',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: session == null ? CreateAccountPage() : MainPage(),
    );
  }
}
