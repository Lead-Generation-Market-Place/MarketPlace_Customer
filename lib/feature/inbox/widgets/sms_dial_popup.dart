import 'package:flutter/cupertino.dart';

class SmsDialPopup extends StatelessWidget {
  final String phoneNumber;
  final VoidCallback onSms;
  final VoidCallback onCancel;

  const SmsDialPopup({
    Key? key,
    required this.phoneNumber,
    required this.onSms,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('Send SMS'),
      content: Text('Would you like to Send SMS to $phoneNumber?'),
      actions: [
        CupertinoDialogAction(child: const Text('Cancel'), onPressed: onCancel),
        CupertinoDialogAction(child: const Text('Send'), onPressed: onSms),
      ],
    );
  }
}
