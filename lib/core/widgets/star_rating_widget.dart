import 'package:flutter/material.dart';

class StarRatingWidget extends StatefulWidget {
  final int maxStars;
  final double initialRating;
  final Function(double) onRatingChanged;

  const StarRatingWidget({
    Key? key,
    this.maxStars = 5,
    this.initialRating = 0,
    required this.onRatingChanged,
  }) : super(key: key);

  @override
  _StarRatingState createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRatingWidget> {
  double _currentRating = 0;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxStars, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = index + 1.0;
              widget.onRatingChanged(_currentRating);
            });
          },
          child: Icon(
            index < _currentRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
        );
      }),
    );
  }
}
