import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gometer/core/widgets/brand_logo.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _mobileDestinations = [
    _NavItem(
      path: '/usage',
      icon: Icons.speed_outlined,
      selectedIcon: Icons.speed,
      label: 'Лимиты',
    ),
    _NavItem(
      path: '/settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Настройки',
    ),
  ];

  static const _desktopDestinations = [
    _NavItem(
      path: '/usage',
      icon: Icons.speed_outlined,
      selectedIcon: Icons.speed,
      label: 'Лимиты',
    ),
    _NavItem(
      path: '/settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Настройки',
    ),
    _NavItem(
      path: '/about',
      icon: Icons.info_outlined,
      selectedIcon: Icons.info,
      label: 'О приложении',
    ),
  ];

  static String _selectedPathForMobile(String location) {
    return switch (location) {
      '/onboarding' || '/key' || '/about' => location,
      _ => location,
    };
  }

  static bool _isFullScreen(String location) =>
      location == '/onboarding' || location == '/key' || location == '/about';

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 600;
    final location = GoRouterState.of(context).matchedLocation;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            _DesktopRail(
              location: location,
              destinations: _desktopDestinations,
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: _isFullScreen(location)
          ? null
          : _BottomNavigationBar(
              selectedPath: _selectedPathForMobile(location),
              destinations: _mobileDestinations,
            ),
    );
  }
}

class _NavItem {
  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem({
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class _DesktopRail extends StatelessWidget {
  final String location;
  final List<_NavItem> destinations;

  const _DesktopRail({required this.location, required this.destinations});

  @override
  Widget build(BuildContext context) {
    final selectedIndex =
        destinations.indexWhere((d) => d.path == location);
    final selected = selectedIndex >= 0 ? selectedIndex : 0;

    return NavigationDrawer(
      selectedIndex: selected,
      onDestinationSelected: (index) => context.go(destinations[index].path),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
          child: BrandLogo(iconSize: 36),
        ),
        for (final item in destinations)
          NavigationDrawerDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: Text(item.label),
          ),
      ],
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  final String selectedPath;
  final List<_NavItem> destinations;

  const _BottomNavigationBar({
    required this.selectedPath,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final selectedIndex =
        destinations.indexWhere((d) => d.path == selectedPath);

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => context.go(destinations[index].path),
      destinations: [
        for (final item in destinations)
          NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: item.label,
          ),
      ],
    );
  }
}
