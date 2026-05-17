// lib/services/video_provider.dart
// State management using Provider pattern

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/job_model.dart';
import '../models/video_options_model.dart';
import 'api_service.dart';

enum AppState { idle, submitting, polling, completed, failed }

class VideoProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  AppState appState = AppState.idle;
  String? currentJobId;
  JobStatus? jobStatus;
  String? errorMessage;
  VideoOptions options = const VideoOptions();
  Timer? _pollTimer;

  bool get isIdle => appState == AppState.idle;
  bool get isLoading => appState == AppState.submitting || appState == AppState.polling;
  bool get isCompleted => appState == AppState.completed;
  bool get isFailed => appState == AppState.failed;

  /// Submit article and start polling
  Future<void> generate(String articleText) async {
    appState = AppState.submitting;
    errorMessage = null;
    jobStatus = null;
    notifyListeners();

    try {
      currentJobId = await _api.generateVideo(articleText, options);
      appState = AppState.polling;
      notifyListeners();
      _startPolling();
    } catch (e) {
      appState = AppState.failed;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
  }

  Future<void> _poll() async {
    if (currentJobId == null) return;
    try {
      final status = await _api.getJobStatus(currentJobId!);
      jobStatus = status;

      if (status.isCompleted) {
        appState = AppState.completed;
        _pollTimer?.cancel();
      } else if (status.isFailed) {
        appState = AppState.failed;
        errorMessage = status.error ?? 'Pipeline failed';
        _pollTimer?.cancel();
      }
      notifyListeners();
    } catch (e) {
      // Network error during polling — keep trying
    }
  }

  void reset() {
    _pollTimer?.cancel();
    appState = AppState.idle;
    currentJobId = null;
    jobStatus = null;
    errorMessage = null;
    notifyListeners();
  }

  String get downloadUrl => currentJobId != null ? _api.getDownloadUrl(currentJobId!) : '';
  String get videoUrl => currentJobId != null ? _api.getVideoUrl(currentJobId!) : '';

  void updateOptions(VideoOptions newOptions) {
    options = newOptions;
    notifyListeners();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
