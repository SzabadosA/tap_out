import 'package:telephony/telephony.dart';
import 'contacts.dart';

// Messenger class handles sending SMS messages to a list of contacts
class Messenger {
  final Telephony telephony =
      Telephony.instance; // Instance of the Telephony plugin

  // Method to send an SMS message to a list of contacts
  Future<void> sendSms(String message, List<Contact> contacts) async {
    for (var contact in contacts) {
      // Send an SMS message to each contact's phone number
      await telephony.sendSms(
        to: contact.phoneNumber,
        message: message,
      );
    }
  }
}
