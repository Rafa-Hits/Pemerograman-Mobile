import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'feedback_model.dart';
import 'feedback_card.dart';

class FeedbackListPage extends StatelessWidget {
  const FeedbackListPage({super.key});

  void _showDeleteDialog(
      BuildContext context, FeedbackModel feedbackModel, String feedbackId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Feedback'),
          content: const Text('Apakah Anda yakin ingin menghapus feedback ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                feedbackModel.removeFeedback(feedbackId);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feedback berhasil dihapus'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Feedback'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FeedbackModel>(
        builder: (context, feedbackModel, child) {
          final feedbacks = feedbackModel.feedbacks;

          if (feedbacks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.feedback_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada feedback',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: feedbacks.length,
            itemBuilder: (context, index) {
              final feedback = feedbacks[index];
              return FeedbackCard(
                feedback: feedback,
                onDelete: () {
                  _showDeleteDialog(context, feedbackModel, feedback.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}