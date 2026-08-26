import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gometer/core/layout/breakpoints.dart';
import 'package:gometer/core/theme/theme_provider.dart';
import 'package:gometer/core/utils/opencode_auth.dart';
import 'package:gometer/core/widgets/app_icon.dart';
import 'package:gometer/core/widgets/filled_text_field.dart';

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

  Future<void> _save() async {
    final error = _validateKey(_controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    await ref.read(settingsProvider.notifier).setApiKey(_controller.text.trim());
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
    final isDesktop = isDesktopLayout(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 640 : double.infinity,
            ),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 12),
                _hero(context),
                const SizedBox(height: 24),
                _keySection(),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.arrow_forward),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  label: const Text('Сохранить и начать'),
                ),
                if (!Platform.isAndroid && !Platform.isIOS) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _importFromCli,
                    icon: const Icon(Icons.file_download),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    label: const Text('Импортировать из opencode CLI'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        const AppIcon(
          size: 116,
          radius: 58,
          image: 'assets/images/png/icon-512.png',
        ),
        const SizedBox(height: 14),
        const Text(
          'GoMeter',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.01,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Трекер лимитов подписки OpenCode Go. Укажи ключ — и поехали.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _keySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ключ доступа',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
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
          helperText:
              'Ключ хранится только в защищённом хранилище устройства и никуда не отправляется.',
        ),
      ],
    );
  }
}
