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
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        border: Border(right: BorderSide(color: scheme.outlineVariant)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 6, 14, 20),
            child: BrandLogo(iconSize: 36),
          ),
          for (final item in destinations) _railItem(context, item),
        ],
      ),
    );
  }

  Widget _railItem(BuildContext context, _NavItem item) {
    final scheme = Theme.of(context).colorScheme;
    final selected = item.path == location;

    return InkWell(
      onTap: () => context.go(item.path),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? scheme.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              selected ? item.selectedIcon : item.icon,
              size: 22,
              color: selected
                  ? scheme.onSecondaryContainer
                  : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 14),
            Flexible(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? scheme.onSecondaryContainer
                      : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
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
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: destinations.map((item) {
            final selected = selectedPath == item.path;
            return InkWell(
              onTap: () => context.go(item.path),
              borderRadius: BorderRadius.circular(22),
              child: Container(
                constraints: const BoxConstraints(minWidth: 96),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      selected ? scheme.secondaryContainer : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selected ? item.selectedIcon : item.icon,
                      size: 26,
                      color: selected
                          ? scheme.onSecondaryContainer
                          : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: selected
                            ? scheme.onSecondaryContainer
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
