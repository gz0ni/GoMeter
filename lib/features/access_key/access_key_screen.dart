import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gometer/core/layout/breakpoints.dart';
import 'package:gometer/core/theme/theme_provider.dart';
import 'package:gometer/core/utils/opencode_auth.dart';
import 'package:gometer/core/widgets/filled_text_field.dart';
import 'package:gometer/core/widgets/page_head.dart';
import 'package:url_launcher/url_launcher.dart';

class AccessKeyScreen extends ConsumerStatefulWidget {
  const AccessKeyScreen({super.key});

  @override
  ConsumerState<AccessKeyScreen> createState() => _AccessKeyScreenState();
}

class _AccessKeyScreenState extends ConsumerState<AccessKeyScreen> {
  final _controller = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String value) {
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
    final err = _validate(_controller.text);
    setState(() => _error = err);
    if (err == null) {
      ref.read(settingsProvider.notifier).setApiKey(_controller.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Сохранено')),
        );
      }
    }
  }

  Future<void> _import() async {
    final token = await importOpencodeAuth();
    if (token == null) {
      setState(() => _error = 'Не удалось найти auth.json.');
      return;
    }
    _controller.text = token;
    setState(() => _error = null);
  }

  Future<void> _openHelp() async {
    await launchUrl(Uri.parse('https://opencode.ai'));
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDesktopLayout(context);
    final scheme = Theme.of(context).colorScheme;

    void goBack() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/usage');
      }
    }

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
                PageHead(
                  title: 'Ключ доступа',
                  showBack: true,
                  onBack: goBack,
                ),
                const SizedBox(height: 12),
                Text(
                  'Подключимся к API OpenCode Go, чтобы показывать лимиты в реальном времени.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
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
                      'Хранится только в защищённом хранилище устройства и никуда не отправляется.',
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  label: const Text('Сохранить'),
                ),
                if (!Platform.isAndroid && !Platform.isIOS) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _import,
                    icon: const Icon(Icons.file_download),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    label: const Text('Импортировать из opencode CLI'),
                  ),
                ],
                const SizedBox(height: 4),
                TextButton(
                  onPressed: _openHelp,
                  child: const Text('Где взять ключ?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
