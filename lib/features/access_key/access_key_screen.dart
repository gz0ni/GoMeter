import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gometer/core/theme/theme_provider.dart';
import 'package:gometer/core/utils/opencode_auth.dart';
import 'package:gometer/core/widgets/filled_text_field.dart';
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
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      appBar: AppBar(
        leading: isMobile
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/usage'),
              )
            : null,
        title: const Text('Ключ доступа'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Подключимся к API OpenCode Go, чтобы показывать твои лимиты в реальном времени.',
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
                'Хранится локально на устройстве и отправляется только в API OpenCode Go.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            label: const Text('Сохранить'),
          ),
          if (!Platform.isAndroid && !Platform.isIOS) ...[
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: _import,
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
          const SizedBox(height: 8),
          TextButton(
            onPressed: _openHelp,
            child: const Text('Где взять ключ?'),
          ),
        ],
      ),
    );
  }
}
