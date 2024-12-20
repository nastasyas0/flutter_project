import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_flutter_app/account.dart';
import 'package:test_flutter_app/bottomNavBar.dart';
import 'package:test_flutter_app/cities.dart';
import 'package:test_flutter_app/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final GoRouter _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => AuthPage(),
          routes: [
            // BottomNavigationBar
            StatefulShellRoute.indexedStack(
              builder: (context, state, navigationShell) => MainBotNavBar(navigationShell: navigationShell),
              branches: [
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/cities',
                      builder: (context, state) => CitiesPage(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/account',
                      builder: (context, state) => AccountPage(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

