import 'package:telephony/telephony.dart';
import 'contacts.dart';

class Messenger {
  final Telephony telephony = Telephony.instance;

  Future<void> sendSms(String message, List<Contact> contacts) async {
    for (var contact in contacts) {
      await telephony.sendSms(
        to: contact.phoneNumber,
        message: message,
      );
    }
  }
}
