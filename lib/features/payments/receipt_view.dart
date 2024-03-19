import 'package:flutter/material.dart';
import 'package:zion_link/core/models/payment.dart';
import 'package:zion_link/core/services/file_upload_service.dart';

class ReceiptView extends StatelessWidget {
  final Payment payment;
  final String attendantName;
  final String buildingAddress;

  const ReceiptView({
    Key? key,
    required this.payment,
    required this.attendantName,
    required this.buildingAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('פרטי קבלה'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('שם הדייר: $attendantName'),
            Text('כתובת הבניין: $buildingAddress'),
            Text('שיטת התשלום: ${payment.paymentMethod}'),
            Text('עבור: וועד'),
            Text('תאריך: ${payment.dateMade}'),
            Text('סכום: ${payment.amount}₪'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('סגור'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('הורד קובץ'),
          onPressed: () async {
            String content = generateReceiptContent();
            // Assuming you want to name the file with the current date and time
            String fileName = 'Receipt_${DateTime.now().toIso8601String()}.txt';
            await FileUploadService.saveContentToFile(fileName, content);
            // Optionally, show a message to the user that the file has been saved
          },
        ),
      ],
    );
  }

  String generateReceiptContent() {
    return '''
שם הדייר: $attendantName
כתובת הבניין: $buildingAddress
שיטת התשלום: ${payment.paymentMethod}
עבור: וועד
תאריך: ${payment.dateMade}
סכום: ${payment.amount}₪
''';
  }
}
