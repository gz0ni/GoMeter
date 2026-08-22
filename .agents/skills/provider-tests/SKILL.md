---
name: provider-tests
description: Use when writing or updating Riverpod provider or notifier tests in this repository.
---

# Provider Tests

## When To Use

Use this for tests covering Riverpod providers and notifiers in `lib/core/theme/theme_provider.dart`, feature providers, and any future state-management code.

## Workflow

1. Use `ProviderContainer` directly or `ProviderScope` for widget-level tests.
2. Override `settingsRepositoryProvider` with a real `SettingsRepository` backed by mocked `SharedPreferences`:

   ```dart
   SharedPreferences.setMockInitialValues({});
   final repo = await SettingsRepository.create();
   final container = ProviderContainer(
     overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
   );
   ```

3. For `AsyncNotifier` tests, await the provider future before mutating state:

   ```dart
   await container.read(settingsProvider.future);
   container.read(settingsProvider.notifier).setThemeMode(AppThemeMode.light);
   await container.pump();
   ```

4. Assert the expected state through the provider.
5. Dispose the `ProviderContainer` in `tearDown`.

## Pitfalls

- Do not test real `SharedPreferences` without `setMockInitialValues`.
- Do not forget to override `settingsRepositoryProvider`; the default provider throws.
- Async notifier state changes are asynchronous; await them in tests.
