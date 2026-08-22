import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gometer/app.dart';
import 'package:gometer/core/router/app_router.dart';
import 'package:gometer/core/settings/settings_repository.dart';
import 'package:gometer/core/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App starts and shows MaterialApp', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = await SettingsRepository.create();
    final router = AppRouter(repo).router;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: GoMeterApp(router: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
