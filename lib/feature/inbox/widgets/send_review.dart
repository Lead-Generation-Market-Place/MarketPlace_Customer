import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:us_connector/core/constants/screen_size.dart';
import 'package:us_connector/core/widgets/custom_button.dart';
import 'package:us_connector/core/widgets/star_rating_widget.dart';

void buildSendReview(BuildContext context) {
  Platform.isAndroid
      ? showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
          ),
          builder: (context) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 16,
                right: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Leave a Review',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  StarRatingWidget(
                    onRatingChanged: (ratings) {
                      print(ratings);
                    },
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Write your review...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  CustomButton(text: 'Submit'),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        )
      : showCupertinoModalPopup(
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
