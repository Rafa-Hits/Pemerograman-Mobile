import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'feedback_model.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  List<Widget> _buildRatingBars(Map<int, int> distribution, int total) {
    List<Widget> widgets = [];

    for (int i = 1; i <= 5; i++) {
      final count = distribution[i] ?? 0;
      final percentage = total > 0 ? (count / total * 100) : 0;

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text('$i Bintang'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: total > 0 ? count / total : 0,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation(_getRatingColor(i)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$count (${percentage.toStringAsFixed(1)}%)'),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Feedback'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FeedbackModel>(
        builder: (context, feedbackModel, child) {
          final summary = feedbackModel.getSummary();
          final total = summary['total'] as int;
          final average = summary['average'] as double;
          final distribution = summary['distribution'] as Map<int, int>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Feedback',
                        total.toString(),
                        Icons.feedback,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Rata-rata Rating',
                        average.toStringAsFixed(1),
                        Icons.star,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Rating Distribution
                const Text(
                  'Distribusi Rating:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                if (total > 0) ..._buildRatingBars(distribution, total),

                if (total == 0)
                  const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Tidak ada data untuk ditampilkan',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}