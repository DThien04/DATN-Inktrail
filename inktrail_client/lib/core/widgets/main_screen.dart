import 'package:flutter/material.dart';
import 'package:ink_trail_client/core/navigation/main_tab_controller.dart';
import 'package:ink_trail_client/core/notifications/notification_navigation_service.dart';
import 'package:ink_trail_client/core/widgets/ink_trail_bottom_nav.dart';
import 'package:ink_trail_client/features/home/presentation/pages/home_api_page.dart';
import 'package:ink_trail_client/features/library/presentation/pages/library_page.dart';
import 'package:ink_trail_client/features/profile/presentation/pages/profile_page.dart';
import 'package:ink_trail_client/features/tags/presentation/pages/tags_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _homePageVersion = 0;
  int _libraryPageVersion = 0;
  int _profilePageVersion = 0;

  @override
  void initState() {
    super.initState();
    MainTabController.register(_onTap);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationNavigationService.markShellReady();
    });
  }

  @override
  void dispose() {
    NotificationNavigationService.markShellNotReady();
    MainTabController.unregister();
    super.dispose();
  }

  void _onTap(int index) {
    setState(() {
      if (index == 0) {
        _homePageVersion++;
      }
      if (index == 2) {
        _libraryPageVersion++;
      }
      if (index == 3) {
        _profilePageVersion++;
      }
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeApiPage(key: ValueKey(_homePageVersion)),
      const TagsPage(),
      LibraryPage(key: ValueKey(_libraryPageVersion)),
      ProfilePage(key: ValueKey(_profilePageVersion)),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: InktrailBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
