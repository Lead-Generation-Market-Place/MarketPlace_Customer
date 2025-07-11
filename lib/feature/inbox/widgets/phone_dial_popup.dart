import 'package:flutter/cupertino.dart';

class PhoneDialPopup extends StatelessWidget {
  final String phoneNumber;
  final VoidCallback onDial;
  final VoidCallback onCancel;

  const PhoneDialPopup({
    Key? key,
    required this.phoneNumber,
    required this.onDial,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('Dial Number'),
      content: Text('Would you like to call $phoneNumber?'),
      actions: [
        CupertinoDialogAction(child: const Text('Cancel'), onPressed: onCancel),
        CupertinoDialogAction(child: const Text('Dial'), onPressed: onDial),
      ],
    );
  }
}



// Usage example:
// showCupertinoDialog(
//   context: context,
//   builder: (context) => PhoneDialPopup(
//     phoneNumber: '123-456-7890',
//     onDial: () {
//       // Implement dial logic here
//       Navigator.of(context).pop();
//     },
//     onCancel: () {
//       Navigator.of(context).pop();
//     },
//   ),
// );

