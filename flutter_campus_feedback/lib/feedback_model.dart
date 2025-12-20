import 'package:flutter/foundation.dart';

class FeedbackItem {
  final String id;
  final String facility;
  final int rating;
  final String comment;
  final DateTime date;

  FeedbackItem({
    required this.id,
    required this.facility,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class FeedbackModel with ChangeNotifier {
  final List<FeedbackItem> _feedbacks = [];

  List<FeedbackItem> get feedbacks => List.unmodifiable(_feedbacks);

  void addFeedback(String facility, int rating, String comment) {
    final newFeedback = FeedbackItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      facility: facility,
      rating: rating,
      comment: comment,
      date: DateTime.now(),
    );

    _feedbacks.add(newFeedback);
    notifyListeners();
  }

  void removeFeedback(String id) {
    _feedbacks.removeWhere((feedback) => feedback.id == id);
    notifyListeners();
  }

  Map<String, dynamic> getSummary() {
    if (_feedbacks.isEmpty) {
      return {
        'total': 0,
        'average': 0.0,
        'distribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      };
    }

    double totalRating = 0;
    Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (var feedback in _feedbacks) {
      totalRating += feedback.rating;
      distribution[feedback.rating] = (distribution[feedback.rating] ?? 0) + 1;
    }

    return {
      'total': _feedbacks.length,
      'average': totalRating / _feedbacks.length,
      'distribution': distribution,
    };
  }
}