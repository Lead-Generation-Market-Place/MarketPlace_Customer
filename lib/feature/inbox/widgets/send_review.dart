import 'package:flutter/cupertino.dart';
import 'package:us_connector/core/widgets/star_rating_widget.dart';

void buildSendReview(BuildContext context) {
  showCupertinoModalPopup(
    builder: (context) => CupertinoActionSheet(
      title: Text('Leave a Review'),
      message: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StarRatingWidget(
            onRatingChanged: (rating) {
              print('Ratings that could be send is: $rating');
            },
          ),
          SizedBox(height: 16),
          CupertinoTextField(
            placeholder: 'Write your feedback...',
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            // Handle submit
            Navigator.of(context).pop();
          },
          child: Text('Submit'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(context).pop(),
        child: Text('Cancel'),
      ),
    ),
    context: context,
  );
}
