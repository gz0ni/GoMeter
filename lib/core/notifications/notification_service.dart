import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationsServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('Override in main() with initialized service');
});

abstract class NotificationService {
  Future<void> init();

  Future<void> show({required String title, required String body});
}
