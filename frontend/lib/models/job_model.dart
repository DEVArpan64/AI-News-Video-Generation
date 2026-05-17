// lib/models/job_model.dart

class SceneData {
  final int index;
  final String text;
  final String imagePrompt;
  final String? imagePath;

  SceneData({
    required this.index,
    required this.text,
    required this.imagePrompt,
    this.imagePath,
  });

  factory SceneData.fromJson(Map<String, dynamic> json) => SceneData(
        index: json['index'] ?? 0,
        text: json['text'] ?? '',
        imagePrompt: json['image_prompt'] ?? '',
        imagePath: json['image_path'],
      );
}

class JobStatus {
  final String jobId;
  final String status; // queued | processing | completed | failed
  final int progress;
  final String currentStep;
  final List<SceneData> scenes;
  final String? videoPath;
  final String? videoUrl;
  final String? error;

  JobStatus({
    required this.jobId,
    required this.status,
    required this.progress,
    required this.currentStep,
    required this.scenes,
    this.videoPath,
    this.videoUrl,
    this.error,
  });

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isProcessing => status == 'processing' || status == 'queued';

  factory JobStatus.fromJson(Map<String, dynamic> json) => JobStatus(
        jobId: json['job_id'] ?? '',
        status: json['status'] ?? 'queued',
        progress: json['progress'] ?? 0,
        currentStep: json['current_step'] ?? '',
        scenes: (json['scenes'] as List<dynamic>? ?? [])
            .map((s) => SceneData.fromJson(s))
            .toList(),
        videoPath: json['video_path'],
        videoUrl: json['video_url'],
        error: json['error'],
      );
}
