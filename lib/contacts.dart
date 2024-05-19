import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Model class for Contact
class Contact {
  final String name;
  final String phoneNumber;

  // Constructor for Contact class
  Contact({required this.name, required this.phoneNumber});
}

// Widget for displaying the contacts page
class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  // List to store contacts
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts(); // Load contacts when the widget is initialized
  }

  // Function to load contacts from shared preferences
  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactData = prefs.getStringList('contacts') ?? [];
    setState(() {
      // Map the stored data to Contact objects and update the contacts list
      contacts = contactData.map((contact) {
        final parts = contact.split('|');
        return Contact(name: parts[0], phoneNumber: parts[1]);
      }).toList();
    });
  }

  // Function to save contacts to shared preferences
  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactData = contacts
        .map((contact) => '${contact.name}|${contact.phoneNumber}')
        .toList();
    await prefs.setStringList('contacts', contactData);
  }

  // Function to show a dialog for adding a new contact
  void _showAddContactDialog() {
    // Controllers to capture text input
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();

    // Show the dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty) {
                  setState(() {
                    // Add new contact to the list
                    contacts.add(Contact(
                        name: nameController.text,
                        phoneNumber: phoneController.text));
                    _saveContacts(); // Save the updated contacts list
                    Navigator.of(context).pop(); // Close the dialog
                  });
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          Contact contact = contacts[index];
          return ListTile(
            title: Text(contact.name),
            subtitle: Text(contact.phoneNumber),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  contacts.removeAt(index); // Remove contact from the list
                  _saveContacts(); // Save the updated contacts list
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog,
        tooltip: 'Add Contact',
        child: const Icon(Icons.add),
      ),
    );
  }
}
