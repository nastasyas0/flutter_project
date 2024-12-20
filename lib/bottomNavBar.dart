import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainBotNavBar extends StatelessWidget {
  const MainBotNavBar({super.key, required this.navigationShell});

  // Контейнер для BottomNavigationBar
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        // Лист элементов для BottomNavigationBar
        items: _buildBottomNavBarItems,
        // Текущий индекс BottomNavigationBar
        currentIndex: navigationShell.currentIndex,
        // Обработчик нажатия на элемент BottomNavigationBar
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }

  // Возвращает лист элементов для BottomNavigationBar
  List<BottomNavigationBarItem> get _buildBottomNavBarItems => [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Cities',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];
}
