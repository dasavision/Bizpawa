import 'package:flutter/material.dart';

class SalesChartPreview extends StatelessWidget {
  const SalesChartPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.orange.withValues(alpha: 0.2)
,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Fake chart bars (preview only)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _bar(40),
              _bar(70),
              _bar(50),
              _bar(90),
              _bar(60),
              _bar(80),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            'Last 7 days',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(double height) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}
