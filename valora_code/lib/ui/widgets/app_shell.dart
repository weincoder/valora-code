import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme/app_theme.dart';
import 'app_background.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  static const _tabs = [
    _TabItem(icon: Icons.home_rounded, label: 'Inicio'),
    _TabItem(icon: Icons.swap_vert_rounded, label: 'Movimientos'),
    _TabItem(icon: Icons.bar_chart_rounded, label: 'Balance'),
    _TabItem(icon: Icons.apps_rounded, label: 'Más'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: navigationShell,
        floatingActionButton: _CenterFab(
          onTap: () => context.push('/register'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _AppBottomBar(
          currentIndex: navigationShell.currentIndex,
          tabs: _tabs,
          onTap: (i) => navigationShell.goBranch(
            i,
            initialLocation: i == navigationShell.currentIndex,
          ),
        ),
      ),
    );
  }
}

// ─── Data ─────────────────────────────────────────────────────────────────────

class _TabItem {
  final IconData icon;
  final String label;

  const _TabItem({required this.icon, required this.label});
}

// ─── Center FAB ───────────────────────────────────────────────────────────────

class _CenterFab extends StatelessWidget {
  final VoidCallback onTap;

  const _CenterFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF8B7FF0), Color(0xFF4233CE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4233CE).withValues(alpha: 0.55),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}

// ─── Bottom bar ───────────────────────────────────────────────────────────────

class _AppBottomBar extends StatelessWidget {
  final int currentIndex;
  final List<_TabItem> tabs;
  final void Function(int) onTap;

  const _AppBottomBar({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      color: AppTheme.navBar,
      padding: EdgeInsets.zero,
      height: 68,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: tabs[0].icon,
            label: tabs[0].label,
            selected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: tabs[1].icon,
            label: tabs[1].label,
            selected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          // Centro vacío para el FAB
          const SizedBox(width: 72),
          _NavItem(
            icon: tabs[2].icon,
            label: tabs[2].label,
            selected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavItem(
            icon: tabs[3].icon,
            label: tabs[3].label,
            selected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF9B8FF5);
    const inactiveColor = Color(0xFF665599);
    final color = selected ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: selected
                    ? activeColor.withValues(alpha: 0.16)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                letterSpacing: 0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
