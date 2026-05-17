// lib/widgets/article_input_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/video_provider.dart';

class ArticleInputWidget extends StatefulWidget {
  const ArticleInputWidget({super.key});

  @override
  State<ArticleInputWidget> createState() => _ArticleInputWidgetState();
}

class _ArticleInputWidgetState extends State<ArticleInputWidget> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const _sampleArticle = '''The Ministry of Science and Technology today announced a landmark initiative to accelerate India's artificial intelligence research ecosystem. The government will establish 25 AI Centers of Excellence across major universities, with a combined investment of Rs 10,000 crore over the next five years.

The initiative aims to position India as a global leader in AI research and development. Union Minister Dr. Jitendra Singh stated that these centers will focus on healthcare AI, agricultural technology, and smart manufacturing.

The program will create approximately 50,000 high-skilled jobs in the AI sector. International collaborations with leading universities in the US, UK, and Japan have already been finalized.

Students and researchers from Tier-2 and Tier-3 cities will receive special scholarships to participate in the program, ensuring inclusive growth in the technology sector across the country.''';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Article / PIB Text',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white)),
              TextButton.icon(
                onPressed: () => _controller.text = _sampleArticle,
                icon: const Icon(Icons.auto_awesome_rounded, size: 14),
                label: const Text('Use Sample', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF6366F1)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controller,
            maxLines: 10,
            validator: (val) {
              if (val == null || val.trim().length < 50) return 'Please enter at least 50 characters';
              return null;
            },
            decoration: const InputDecoration(
              hintText: 'Paste your news article or PIB press release here...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Consumer<VideoProvider>(
              builder: (context, provider, _) {
                return ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      provider.generate(_controller.text.trim());
                    }
                  },
                  icon: const Icon(Icons.movie_creation_rounded),
                  label: const Text('Generate Video', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
