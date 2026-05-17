// lib/models/video_options_model.dart

class VideoOptions {
  final String voice;
  final String style;
  final int durationPerScene;
  final bool addSubtitles;
  final int maxScenes;

  const VideoOptions({
    this.voice = 'en',
    this.style = 'news',
    this.durationPerScene = 4,
    this.addSubtitles = true,
    this.maxScenes = 5,
  });

  Map<String, dynamic> toJson() => {
        'voice': voice,
        'style': style,
        'duration_per_scene': durationPerScene,
        'add_subtitles': addSubtitles,
        'max_scenes': maxScenes,
      };

  VideoOptions copyWith({
    String? voice,
    String? style,
    int? durationPerScene,
    bool? addSubtitles,
    int? maxScenes,
  }) =>
      VideoOptions(
        voice: voice ?? this.voice,
        style: style ?? this.style,
        durationPerScene: durationPerScene ?? this.durationPerScene,
        addSubtitles: addSubtitles ?? this.addSubtitles,
        maxScenes: maxScenes ?? this.maxScenes,
      );
}
