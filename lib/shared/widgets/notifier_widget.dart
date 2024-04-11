import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_sms/flutter_sms.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tachles/shared/widgets/success_message_widget.dart';
import 'package:tachles/shared/widgets/error_message_widget.dart';

/// A widget that displays a message icon and sends messages via SMS, WhatsApp, Telegram, or Viber.
class NotifierWidget extends StatelessWidget {
  final String message;
  final String phoneNumber;
  final String? tooltip;

  const NotifierWidget({
    Key? key,
    required this.phoneNumber,
    this.tooltip,
    this.message = '', // Set a default value for message
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.send),
      tooltip: tooltip,
      onPressed: () async {
        if (message.isEmpty) {
          // If message is empty, prompt the user for a message
          final TextEditingController controller = TextEditingController();
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('מה תרצה לשלוח?'),
                content: TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: 'Message'),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('שלח'),
                    onPressed: () {
                      Navigator.of(context).pop(controller.text);
                    },
                  ),
                ],
              );
            },
          ).then((value) {
            if (value != null) {
              // If the user entered a message, use it
              _sendMessage(value, phoneNumber, context);
            } else {
              ScaffoldMessenger.of(context)
                  .showSnackBar(ErrorMessageWidget.create(
                message: 'לא הצלחנו לשלח הודעה',
              ));
            }
          });
        } else {
          // If message is not empty, send the message
          _sendMessage(message, phoneNumber, context);
        }
      },
    );
  }

  /// Sends an SMS message using the flutter_sms package.
  Future<void> _sendSMS(
      String phoneNumber, String message, BuildContext context) async {
    try {
      final List<String> recipients = [phoneNumber];
      await sendSMS(message: message, recipients: recipients)
          .catchError((error) => throw Exception('Failed to send SMS $error'));
      ScaffoldMessenger.of(context).showSnackBar(SuccessMessageWidget.create(
        message: 'הודעה סמס נשלחה בהצלחה',
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(ErrorMessageWidget.create(
        message: 'לא הצלחנו לשלח הודעה',
      ));
      print(e);
    }
  }

  /// Sends a message via WhatsApp, Telegram, or Viber based on availability.
  Future<void> _sendMessageViaApp(
      String phoneNumber, String message, BuildContext context) async {
    bool messageSent = false;

    // Attempt to send via WhatsApp
    final Uri whatsappUri = Uri.parse(
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(whatsappUri)) {
      messageSent = await launchUrl(whatsappUri);
      if (messageSent) {
        ScaffoldMessenger.of(context).showSnackBar(SuccessMessageWidget.create(
          message: 'הודעה נשלחה בהצלחה באמצעות WhatsApp',
        ));
        return;
      }
    }

    // Attempt to send via Telegram
    final Uri telegramUri = Uri.parse(
        'tg://msg?text=${Uri.encodeComponent(message)}&to=$phoneNumber');
    if (!messageSent && await canLaunchUrl(telegramUri)) {
      messageSent = await launchUrl(telegramUri);
      if (messageSent) {
        ScaffoldMessenger.of(context).showSnackBar(SuccessMessageWidget.create(
          message: 'הודעה נשלחה בהצלחה באמצעות Telegram',
        ));
        return;
      }
    }

    // Attempt to send via Viber
    final Uri viberUri = Uri.parse(
        'viber://chat?number=$phoneNumber&text=${Uri.encodeComponent(message)}');
    if (!messageSent && await canLaunchUrl(viberUri)) {
      messageSent = await launchUrl(viberUri);
      if (messageSent) {
        ScaffoldMessenger.of(context).showSnackBar(SuccessMessageWidget.create(
          message: 'הודעה נשלחה בהצלחה באמצעות Viber',
        ));
        return;
      }
    }

    if (!messageSent) {
      ScaffoldMessenger.of(context).showSnackBar(ErrorMessageWidget.create(
        message: 'לא הצלחנו לשלח הודעה',
      ));
    }
  }

  /// Sends a message via SMS, WhatsApp, Telegram, or Viber based on availability and user input.
  Future<void> _sendMessage(
      String message, String phoneNumber, BuildContext context) async {
    if (kIsWeb) {
      await _sendSMS(phoneNumber, message, context);
    } else if (Platform.isAndroid || Platform.isIOS) {
      await _sendSMS(phoneNumber, message, context);
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await _sendMessageViaApp(phoneNumber, message, context);
    } else {
      throw Exception('Unsupported platform');
    }
  }

  /// Opens WhatsApp with the specified phone number and message.
  Future<void> _openWhatsApp(String phoneNumber, String message) async {
    final String url =
        'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}';
    await launchUrl(Uri.parse(url));
  }

  /// Opens Telegram with the specified phone number and message.
  Future<void> _openTelegram(String phoneNumber, String message) async {
    final String url =
        'tg://msg?to=$phoneNumber&text=${Uri.encodeComponent(message)}';
    await launchUrl(Uri.parse(url));
  }

  /// Opens Viber with the specified phone number and message.
  Future<void> _openViber(String phoneNumber, String message) async {
    final String url =
        'viber://chat?number=$phoneNumber&text=${Uri.encodeComponent(message)}';
    await launchUrl(Uri.parse(url));
  }
}
