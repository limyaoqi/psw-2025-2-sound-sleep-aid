import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'widgets/idle_shutdown.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRouter.initialRoute(),
      routes: AppRouter.routes,
      builder: (context, child) => IdleShutdown(
        timeout: const Duration(seconds: 10), // test: 10s idle shutdown
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
