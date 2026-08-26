import 'package:flutter/material.dart';

class SettingRow extends StatelessWidget {
  final String label;
  final String? sub;
  final Widget? subWidget;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  const SettingRow({
    super.key,
    required this.label,
    this.sub,
    this.subWidget,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final content = Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: danger ? scheme.error : scheme.onSurface,
                ),
              ),
              if (sub != null)
                Text(
                  sub!,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                )
              else
                ?subWidget,
            ],
          ),
        ),
        if (trailing != null)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: trailing!,
          ),
      ],
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: content,
      ),
    );
  }
}

class SwitchRow extends StatelessWidget {
  final String label;
  final String? sub;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SwitchRow({
    super.key,
    required this.label,
    this.sub,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SettingRow(
      label: label,
      sub: sub,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: scheme.onPrimary,
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool showDivider;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minWidth: double.infinity),
      decoration: showDivider
          ? BoxDecoration(
              border: Border(top: BorderSide(color: scheme.outlineVariant)),
            )
          : null,
      padding: EdgeInsets.only(top: showDivider ? 18 : 4, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}
