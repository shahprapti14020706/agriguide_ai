import 'package:flutter/material.dart';

class SuggestedQuestionsWidget extends StatelessWidget {
  const SuggestedQuestionsWidget({
    required this.onSelected,
    super.key,
  });

  final ValueChanged<String> onSelected;

  static const questions = [
    'What should I do during flowering stage?',
    'How often should I irrigate my crop?',
    'How can I improve soil health?',
    'What are signs of pest attack?',
    'When should I apply fertilizer?',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: questions
          .map(
            (question) => ActionChip(
              avatar: const Icon(Icons.eco_outlined, size: 18),
              label: Text(question),
              onPressed: () => onSelected(question),
            ),
          )
          .toList(growable: false),
    );
  }
}
