import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'installer.dart';
import 'update_service.dart';
import 'update_state.dart';

final updateServiceProvider = Provider<UpdateService>((ref) {
  throw UnimplementedError('Override in main() with initialized service');
});

final updateControllerProvider =
    NotifierProvider<UpdateController, UpdateState>(UpdateController.new);

class UpdateController extends Notifier<UpdateState> {
  UpdateService? _service;

  @override
  UpdateState build() {
    _service = ref.watch(updateServiceProvider);
    return const UpdateState();
  }

  Future<void> check({bool isUser = false}) async {
    final service = _service;
    if (service == null) return;
    state = state.copyWith(status: UpdateStatus.checking);
    try {
      final release = await service.checkForUpdate();
      if (release != null) {
        state = UpdateState(status: UpdateStatus.available, info: release);
      } else {
        state = const UpdateState(status: UpdateStatus.idle);
      }
    } catch (e) {
      state = UpdateState(
        status: UpdateStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> downloadAndInstall() async {
    final service = _service;
    final info = state.info;
    if (service == null || info == null) return;

    final asset = service.pickAsset(info);
    if (asset == null) {
      state = state.copyWith(
        status: UpdateStatus.error,
        error: 'Не найден файл обновления для этой платформы',
      );
      return;
    }

    final dir = await getApplicationSupportDirectory();
    state = state.copyWith(status: UpdateStatus.downloading, progress: 0);
    try {
      final path = await service.downloadAsset(
        asset,
        dir.path,
        (received, total) {
          final progress = total > 0 ? received / total : 0.0;
          state = state.copyWith(progress: progress);
        },
      );
      state = state.copyWith(status: UpdateStatus.ready, filePath: path);
      await _install();
    } catch (e) {
      state = state.copyWith(status: UpdateStatus.error, error: e.toString());
    }
  }

  Future<void> installFromReady() async => _install();

  Future<void> _install() async {
    final path = state.filePath;
    if (path == null) return;
    state = state.copyWith(status: UpdateStatus.installing);
    try {
      await Installer().install(path);
      state = state.copyWith(status: UpdateStatus.done);
    } catch (e) {
      state = state.copyWith(status: UpdateStatus.error, error: e.toString());
    }
  }

  void dismiss() {
    state = const UpdateState(status: UpdateStatus.idle);
  }
}
