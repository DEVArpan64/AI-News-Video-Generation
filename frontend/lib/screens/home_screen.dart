// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/video_provider.dart';
import '../widgets/article_input_widget.dart';
import '../widgets/processing_widget.dart';
import '../widgets/result_widget.dart';
import '../widgets/options_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: Consumer<VideoProvider>(
                builder: (context, provider, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (provider.isIdle) ...[
                        _buildHero(context),
                        const SizedBox(height: 32),
                        const ArticleInputWidget(),
                        const SizedBox(height: 16),
                        const OptionsWidget(),
                      ] else if (provider.isLoading) ...[
                        const ProcessingWidget(),
                      ] else if (provider.isCompleted) ...[
                        const ResultWidget(),
                      ] else if (provider.isFailed) ...[
                        _buildError(context, provider),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: const Color(0xFF0F172A),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.video_camera_back_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'Article2Video',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.5)),
            ),
            child: const Text('AI', style: TextStyle(color: Color(0xFF6366F1), fontSize: 11)),
          ),
        ],
      ),
      actions: [
        Consumer<VideoProvider>(
          builder: (context, provider, _) {
            if (!provider.isIdle) {
              return IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Start over',
                onPressed: provider.reset,
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'News → Video\nin seconds',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Paste any PIB or news article. Our AI pipeline summarizes it, generates scene images, adds voice narration, and renders a complete MP4 video.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15, height: 1.6),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _chip(Icons.psychology_rounded, 'AI Summarization'),
              _chip(Icons.image_rounded, 'Scene Images'),
              _chip(Icons.record_voice_over_rounded, 'Voice Narration'),
              _chip(Icons.subtitles_rounded, 'Subtitles'),
              _chip(Icons.download_rounded, 'MP4 Export'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6366F1)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, VideoProvider provider) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF7F1D1D).withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 48),
              const SizedBox(height: 16),
              const Text('Generation Failed', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text(provider.errorMessage ?? 'Unknown error', style: const TextStyle(color: Color(0xFF94A3B8))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: provider.reset,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Try Again'),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
        ),
      ],
    );
  }
}
