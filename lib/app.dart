import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gometer/core/theme/app_theme.dart';
import 'package:gometer/core/theme/theme_provider.dart';
import 'package:gometer/core/update/update_controller.dart';

class GoMeterApp extends ConsumerStatefulWidget {
  final GoRouter router;

  const GoMeterApp({super.key, required this.router});

  @override
  ConsumerState<GoMeterApp> createState() => _GoMeterAppState();
}

class _GoMeterAppState extends ConsumerState<GoMeterApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoCheck());
  }

  Future<void> _autoCheck() async {
    final settings = await ref.read(settingsProvider.future);
    if (settings.autoCheckUpdate) {
      await ref.read(updateControllerProvider.notifier).check();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      data: (settings) {
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        final theme = buildTheme(settings, brightness);

        return MaterialApp.router(
          title: 'GoMeter',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [
            Locale('ru', 'RU'),
            Locale('en', 'US'),
          ],
          locale: const Locale('ru', 'RU'),
          theme: theme,
          routerConfig: widget.router,
        );
      },
      loading: () => const MaterialApp(home: SizedBox.shrink()),
      error: (e, _) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Ошибка: $e'))),
      ),
    );
  }
}
