import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gometer/core/settings/settings_repository.dart';
import 'package:gometer/core/theme/app_theme.dart';
import 'package:gometer/core/theme/theme_provider.dart';
import 'package:gometer/core/widgets/color_dot.dart';
import 'package:gometer/core/widgets/filter_chip.dart';
import 'package:gometer/core/widgets/filled_text_field.dart';
import 'package:gometer/core/utils/opencode_auth.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validateKey(String value) {
    final t = value.trim();
    if (t.isEmpty) return 'Введи ключ — он начинается с sk-.';
    if (!t.startsWith('sk-')) {
      return 'Похоже, это не ключ OpenCode Go — он начинается с «sk-».';
    }
    if (t.length < 10) {
      return 'Ключ слишком короткий. Проверь, что скопировал его целиком.';
    }
    return null;
  }

  void _save() {
    final error = _validateKey(_controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    ref.read(settingsProvider.notifier).setApiKey(_controller.text.trim());
    if (mounted) context.go('/usage');
  }

  Future<void> _importFromCli() async {
    final token = await importOpencodeAuth();
    if (token == null) {
      setState(() => _error = 'Не удалось найти auth.json. Убедись, что opencode CLI авторизован.');
      return;
    }
    _controller.text = token;
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).value ?? const AppSettings();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 24),
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: scheme.primaryContainer,
                child: Icon(
                  Icons.speed,
                  size: 48,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Добро пожаловать в GoMeter',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            const Text(
              'Трекер лимитов подписки OpenCode Go. Настроим за минуту.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _sectionTitle('Тема'),
            Wrap(
              spacing: 8,
              children: AppThemeMode.values.map((mode) {
                return FilterChipWidget(
                  label: switch (mode) {
                    AppThemeMode.light => 'Светлая',
                    AppThemeMode.dark => 'Тёмная',
                    AppThemeMode.system => 'Системная',
                  },
                  selected: settings.themeMode == mode,
                  onSelected: (_) =>
                      ref.read(settingsProvider.notifier).setThemeMode(mode),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Цвет акцента'),
            Wrap(
              spacing: 12,
              children: AccentSeed.values.map((seed) {
                return ColorDot(
                  isAuto: seed == AccentSeed.auto,
                  color: seed == AccentSeed.auto ? null : seed.color,
                  selected: settings.seed == seed,
                  onTap: () =>
                      ref.read(settingsProvider.notifier).setSeed(seed),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Ключ доступа'),
            FilledTextField(
              controller: _controller,
              obscureText: _obscure,
              labelText: 'Ключ API',
              hintText: 'sk-...',
              errorText: _error,
              prefixIcon: const Icon(Icons.vpn_key),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              helperText: 'Ключ хранится локально на устройстве.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              label: const Text('Сохранить и начать'),
            ),
            if (!Platform.isAndroid && !Platform.isIOS) ...[
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: _importFromCli,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Импортировать из opencode CLI'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    );
  }
}
