import 'release_info.dart';

enum UpdateStatus {
  idle,
  checking,
  available,
  downloading,
  ready,
  installing,
  done,
  error,
}

class UpdateState {
  final UpdateStatus status;
  final ReleaseInfo? info;
  final double progress;
  final String? filePath;
  final String? error;

  const UpdateState({
    this.status = UpdateStatus.idle,
    this.info,
    this.progress = 0,
    this.filePath,
    this.error,
  });

  UpdateState copyWith({
    UpdateStatus? status,
    ReleaseInfo? info,
    double? progress,
    String? filePath,
    String? error,
  }) {
    return UpdateState(
      status: status ?? this.status,
      info: info ?? this.info,
      progress: progress ?? this.progress,
      filePath: filePath ?? this.filePath,
      error: error ?? this.error,
    );
  }
}
