// lib/widgets/options_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/video_provider.dart';
import '../models/video_options_model.dart';

class OptionsWidget extends StatefulWidget {
  const OptionsWidget({super.key});

  @override
  State<OptionsWidget> createState() => _OptionsWidgetState();
}

class _OptionsWidgetState extends State<OptionsWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoProvider>(
      builder: (context, provider, _) {
        final opts = provider.options;
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(
            children: [
              ListTile(
                onTap: () => setState(() => _expanded = !_expanded),
                title: const Text('Video Options', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: Text('${opts.maxScenes} scenes • ${opts.durationPerScene}s each',
                    style: const TextStyle(color: Color(0xFF475569), fontSize: 12)),
                trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF6366F1)),
              ),
              if (_expanded) ...[
                const Divider(color: Color(0xFF334155), height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _slider('Scenes', opts.maxScenes.toDouble(), 2, 8, (v) {
                        provider.updateOptions(opts.copyWith(maxScenes: v.toInt()));
                      }),
                      const SizedBox(height: 12),
                      _slider('Duration per scene (s)', opts.durationPerScene.toDouble(), 2, 8, (v) {
                        provider.updateOptions(opts.copyWith(durationPerScene: v.toInt()));
                      }),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Add Subtitles', style: TextStyle(color: Colors.white, fontSize: 14)),
                        value: opts.addSubtitles,
                        activeColor: const Color(0xFF6366F1),
                        onChanged: (v) => provider.updateOptions(opts.copyWith(addSubtitles: v)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _slider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
            Text(value.toInt().toString(),
                style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          activeColor: const Color(0xFF6366F1),
          inactiveColor: const Color(0xFF334155),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
