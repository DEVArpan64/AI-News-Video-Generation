// lib/services/api_service.dart
// Handles all HTTP communication with the FastAPI backend

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job_model.dart';
import '../models/video_options_model.dart';

class ApiService {
  // Change this to your backend URL
  static const String baseUrl = 'http://localhost:8000/api/v1';

  /// Submit article for video generation
  Future<String> generateVideo(String articleText, VideoOptions options) async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'article_text': articleText,
        'options': options.toJson(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['job_id'] as String;
    }
    throw Exception('Failed to start generation: ${response.body}');
  }

  /// Poll job status
  Future<JobStatus> getJobStatus(String jobId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/status/$jobId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return JobStatus.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to get status: ${response.body}');
  }

  /// Get download URL for the video
  String getDownloadUrl(String jobId) {
    return 'http://localhost:8000/api/v1/download/$jobId';
  }

  /// Get video stream URL (for playback)
  String getVideoUrl(String jobId) {
    return 'http://localhost:8000/outputs/$jobId/output.mp4';
  }
}
