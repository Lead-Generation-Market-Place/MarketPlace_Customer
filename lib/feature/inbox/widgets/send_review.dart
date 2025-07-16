import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:us_connector/core/widgets/custom_button.dart';
import 'package:us_connector/core/widgets/star_rating_widget.dart';
import 'package:us_connector/feature/inbox/controller/single_chat_controller.dart';

void buildSendReview(BuildContext context, SingleChatController controller) {
  final TextEditingController reviewTextController = TextEditingController(
    text: controller.review['review_text'] ?? '',
  );
  int ratings = controller.review['rating'] ?? 0;

  final Widget sheetContent = StatefulBuilder(
    //first get reviews
    builder: (context, setState) {
      return controller.isReviewLoading.value
          ? Center(child: CircularProgressIndicator.adaptive())
          : Padding(
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
                    initialRating: ratings,
                    onRatingChanged: (newRating) {
                      setState(() => ratings = newRating);
                    },
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: reviewTextController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Write your review...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  CustomButton(
                    text: 'Submit',
                    onPressed: () {
                      //  controller.sendReview(reviewTextController.text, ratings);
                      //  Navigator.of(context).pop(); // Close modal after submission
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
    },
  );

  if (Platform.isAndroid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
      ),
      builder: (_) => sheetContent,
    ).whenComplete(() => reviewTextController.dispose()); // Dispose when closed
  } else {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Leave a Review'),
        message: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StarRatingWidget(
                  initialRating: ratings,
                  onRatingChanged: (newRating) {
                    setState(() => ratings = newRating);
                  },
                ),
                const SizedBox(height: 16),
                CupertinoTextField(
                  controller: reviewTextController,
                  maxLines: 3,
                  placeholder: 'Write your feedback...',
                ),
              ],
            );
          },
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              //   controller.sendReview(reviewTextController.text, ratings);
              Navigator.of(context).pop();
            },
            child: const Text('Submit'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    ).whenComplete(() => reviewTextController.dispose()); // Dispose safely
  }
}
