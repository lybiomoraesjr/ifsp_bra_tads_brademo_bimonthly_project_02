import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/ui/navigation_item.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/category_page.dart';
import 'package:flutter_application_1/pages/profile_page.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

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

  List<NavigationItem> get navigationItems => _navigationItems;

  NavigationItem get currentItem => _navigationItems[_currentIndex];

  void setIndex(int index) {
    if (index != _currentIndex) {
      _currentIndex = index;
      notifyListeners();
    }
  }
} 