import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

enum AccentSeed {
  auto,
  blue,
  violet,
  green,
  orange,
  pink;

  static AccentSeed fromName(String? name) => AccentSeed.values.firstWhere(
        (e) => e.name == name,
        orElse: () => AccentSeed.blue,
      );
}

class AppSettings {
  final AppThemeMode themeMode;
  final AccentSeed seed;
  final String apiKey;
  final int checkIntervalMinutes;
  final bool notificationsEnabled;
  final bool threshold80;
  final bool threshold95;
  final bool bannerDismissed;
  final bool autoCheckUpdate;

  const AppSettings({
    this.themeMode = AppThemeMode.dark,
    this.seed = AccentSeed.blue,
    this.apiKey = '',
    this.checkIntervalMinutes = 5,
    this.notificationsEnabled = true,
    this.threshold80 = true,
    this.threshold95 = true,
    this.bannerDismissed = false,
    this.autoCheckUpdate = true,
  });

  bool get keySet => apiKey.isNotEmpty;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    AccentSeed? seed,
    String? apiKey,
    int? checkIntervalMinutes,
    bool? notificationsEnabled,
    bool? threshold80,
    bool? threshold95,
    bool? bannerDismissed,
    bool? autoCheckUpdate,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        seed: seed ?? this.seed,
        apiKey: apiKey ?? this.apiKey,
        checkIntervalMinutes: checkIntervalMinutes ?? this.checkIntervalMinutes,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        threshold80: threshold80 ?? this.threshold80,
        threshold95: threshold95 ?? this.threshold95,
        bannerDismissed: bannerDismissed ?? this.bannerDismissed,
        autoCheckUpdate: autoCheckUpdate ?? this.autoCheckUpdate,
      );
}

class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  static Future<SettingsRepository> create() async =>
      SettingsRepository(await SharedPreferences.getInstance());

  AppSettings load() {
    return AppSettings(
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == (_prefs.getString('themeMode') ?? AppThemeMode.dark.name),
        orElse: () => AppThemeMode.dark,
      ),
      seed: AccentSeed.fromName(_prefs.getString('seed')),
      apiKey: _prefs.getString('apiKey') ?? '',
      checkIntervalMinutes: _prefs.getInt('checkIntervalMinutes') ?? 5,
      notificationsEnabled: _prefs.getBool('notificationsEnabled') ?? true,
      threshold80: _prefs.getBool('threshold80') ?? true,
      threshold95: _prefs.getBool('threshold95') ?? true,
      bannerDismissed: _prefs.getBool('bannerDismissed') ?? false,
      autoCheckUpdate: _prefs.getBool('autoCheckUpdate') ?? true,
    );
  }

  Future<void> save(AppSettings settings) async {
    await _prefs.setString('themeMode', settings.themeMode.name);
    await _prefs.setString('seed', settings.seed.name);
    await _prefs.setString('apiKey', settings.apiKey);
    await _prefs.setInt('checkIntervalMinutes', settings.checkIntervalMinutes);
    await _prefs.setBool('notificationsEnabled', settings.notificationsEnabled);
    await _prefs.setBool('threshold80', settings.threshold80);
    await _prefs.setBool('threshold95', settings.threshold95);
    await _prefs.setBool('bannerDismissed', settings.bannerDismissed);
    await _prefs.setBool('autoCheckUpdate', settings.autoCheckUpdate);
  }
}
