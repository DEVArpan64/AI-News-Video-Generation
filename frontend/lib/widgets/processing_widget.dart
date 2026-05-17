// lib/widgets/processing_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../services/video_provider.dart';

class ProcessingWidget extends StatelessWidget {
  const ProcessingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoProvider>(
      builder: (context, provider, _) {
        final status = provider.jobStatus;
        final progress = (status?.progress ?? 0) / 100.0;
        final step = status?.currentStep ?? 'Starting pipeline...';
        final scenes = status?.scenes ?? [];

        return Column(
          children: [
            // Progress card
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                children: [
                  CircularPercentIndicator(
                    radius: 70.0,
                    lineWidth: 8.0,
                    percent: progress,
                    center: Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    progressColor: const Color(0xFF6366F1),
                    backgroundColor: const Color(0xFF334155),
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                    animateFromLastPercent: true,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    step,
                    style: const TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  _buildStepIndicators(status?.progress ?? 0),
                ],
              ),
            ),

            // Scenes list (populated as pipeline runs)
            if (scenes.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Generated Scenes',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white)),
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: scenes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final scene = scenes[i];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text('${scene.index + 1}',
                                style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(scene.text,
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.5)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStepIndicators(int progress) {
    final steps = [
      ('Analyze', 10),
      ('Images', 55),
      ('Audio', 75),
      ('Render', 95),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: steps.map((s) {
          final done = progress >= s.$2;
          final active = progress >= s.$2 - 25 && !done;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Icon(
                  done ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: done ? const Color(0xFF6366F1) : active ? const Color(0xFF94A3B8) : const Color(0xFF334155),
                  size: 18,
                ),
                const SizedBox(height: 4),
                Text(s.$1,
                    style: TextStyle(
                        fontSize: 10,
                        color: done ? const Color(0xFF6366F1) : const Color(0xFF475569))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
