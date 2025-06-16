import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/ui/navigation_item.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/category_page.dart';
import 'package:flutter_application_1/pages/profile_page.dart';
import 'package:flutter_application_1/widgets/navigation/custom_bottom_navigation.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    const NavigationItem(
      label: 'Início',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      page: HomePage(),
    ),
    const NavigationItem(
      label: 'Categorias',
      icon: Icons.category_outlined,
      selectedIcon: Icons.category,
      page: CategoryPage(),
    ),
    const NavigationItem(
      label: 'Perfil',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      page: ProfilePage(),
    ),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _navigationItems.map((item) => item.page).toList(),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        items: _navigationItems,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
} 