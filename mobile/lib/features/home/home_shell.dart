import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'custom_bottom_nav.dart';

class HomeShell extends StatelessWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/vocab')) return 1;
    if (location.startsWith('/practice')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0; // / is Path
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/vocab');
        break;
      case 2:
        context.go('/practice');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}
