import 'package:flutter/material.dart';
import 'package:ink_trail_client/core/widgets/main_screen.dart';
import 'package:ink_trail_client/features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  // Route names
  static const splash = '/splash';
  static const home = '/';
  static const storyDetail = '/story-detail';
  static const reader = '/reader';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fade(const SplashPage());
      case home:
        return _fade(const MainScreen());
      case storyDetail:
        return _fade(
          const Scaffold(body: Center(child: Text('Detail — coming soon'))),
        );
      case reader:
        return _fade(
          const Scaffold(body: Center(child: Text('Reader — coming soon'))),
        );
      default:
        return _fade(
          const Scaffold(
            body: Center(child: Text('404 — Không tìm thấy trang')),
          ),
        );
    }
  }

  static PageRouteBuilder _fade(Widget page) => PageRouteBuilder(
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 200),
  );

  static Future<T?> push<T>(String route, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(route, arguments: arguments);
  }

  static void pushReplacement(String route, {Object? arguments}) {
    navigatorKey.currentState?.pushReplacementNamed(
      route,
      arguments: arguments,
    );
  }

  static void pop<T>({T? result}) {
    navigatorKey.currentState?.pop(result);
  }
}
