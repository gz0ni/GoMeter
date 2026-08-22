import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _railExtended = false;

  static const _mobileDestinations = [
    _NavItem(
      path: '/usage',
      icon: Icons.speed_outlined,
      selectedIcon: Icons.speed,
      label: 'Использование',
    ),
    _NavItem(
      path: '/notifications',
      icon: Icons.notifications_outlined,
      selectedIcon: Icons.notifications,
      label: 'Уведомления',
    ),
    _NavItem(
      path: '/settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Настройки',
    ),
  ];

  static const _desktopDestinations = [
    ..._mobileDestinations,
    _NavItem(
      path: '/key',
      icon: Icons.key_outlined,
      selectedIcon: Icons.key,
      label: 'Ключ',
    ),
    _NavItem(
      path: '/about',
      icon: Icons.info_outlined,
      selectedIcon: Icons.info,
      label: 'О приложении',
    ),
  ];

  String _selectedPathForMobile(String location) {
    return switch (location) {
      '/key' => '/usage',
      '/about' => '/settings',
      _ => location,
    };
  }

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
              extended: _railExtended,
              onToggleExtended: () {
                setState(() => _railExtended = !_railExtended);
              },
            ),
            const VerticalDivider(width: 1),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _PillNavigationBar(
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

class _PillNavigationBar extends StatelessWidget {
  final String selectedPath;
  final List<_NavItem> destinations;

  const _PillNavigationBar({
    required this.selectedPath,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: destinations.map((item) {
                final selected = selectedPath == item.path;
                return _PillItem(
                  item: item,
                  selected: selected,
                  onTap: () => context.go(item.path),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillItem extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _PillItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 112,
        height: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 32,
              decoration: BoxDecoration(
                color: selected ? scheme.secondaryContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(
                selected ? item.selectedIcon : item.icon,
                color: selected
                    ? scheme.onSecondaryContainer
                    : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
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
  }
}

class _DesktopRail extends StatelessWidget {
  final String location;
  final List<_NavItem> destinations;
  final bool extended;
  final VoidCallback onToggleExtended;

  const _DesktopRail({
    required this.location,
    required this.destinations,
    required this.extended,
    required this.onToggleExtended,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selectedIndex = destinations.indexWhere(
      (item) => item.path == location,
    );

    return NavigationRail(
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      extended: extended,
      labelType: extended ? NavigationRailLabelType.all : NavigationRailLabelType.none,
      onDestinationSelected: (index) => context.go(destinations[index].path),
      leading: IconButton(
        onPressed: onToggleExtended,
        icon: Icon(extended ? Icons.chevron_left : Icons.chevron_right),
      ),
      destinations: destinations
          .map(
            (item) => NavigationRailDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: Text(item.label),
            ),
          )
          .toList(),
      backgroundColor: scheme.surface,
    );
  }
}
