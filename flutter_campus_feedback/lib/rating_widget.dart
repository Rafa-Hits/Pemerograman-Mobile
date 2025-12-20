import 'package:flutter/material.dart';

class RatingWidget extends StatefulWidget {
  final int initialRating;
  final Function(int) onRatingChanged;

  const RatingWidget({
    super.key,
    required this.initialRating,
    required this.onRatingChanged,
  });

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final rating = index + 1;
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentRating = rating;
              });
              widget.onRatingChanged(rating);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: rating <= _currentRating
                    ? _getRatingColor(rating).withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: rating <= _currentRating
                      ? _getRatingColor(rating)
                      : Colors.grey.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                rating <= _currentRating
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: rating <= _currentRating
                    ? _getRatingColor(rating)
                    : Colors.grey,
                size: 32,
              ),
            ),
          );
        }),
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
        return Colors.yellow.shade700;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}