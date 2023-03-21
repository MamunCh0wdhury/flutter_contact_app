import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactPage extends StatefulWidget {


   const ContactPage({Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Contact> contacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _contactPermission();
  }

  // request user to get access to phone contacts

  void _contactPermission() async {
    if (await Permission.contacts.isGranted) {
      //fetch all contacts
      _fetchContacts();
    } else {
      Permission.contacts.request();
    }
  }

  void _fetchContacts() async {
    contacts = await ContactsService.getContacts();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> deleteContact(Contact contact,) async {

    await ContactsService.deleteContact(contact);
setState(() {
contacts.remove(contact);
});
  }

  Future<void> updateContact(Contact contact) async {
    await ContactsService.openExistingContact(contact);
    _fetchContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacts"),
        elevation: 0.0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            Contact contact =contacts[index];
            return ListTile(
              leading: Text(contacts[index].displayName![0]),
              title: Text(contacts[index].displayName!),
              subtitle:Text(contact.phones!.isNotEmpty
                  ? contact.phones!.first.value ?? ''
                  : ''), //Text(contacts[index].phones![0].value!),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Edit Contact'),
                        content: Text(
                            ' ${contact.displayName}?'
                        ),
                        actions: [
                          TextButton(
                            child: const Text('CANCEL'),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: const Text('EDIT'),
                            onPressed: () {
                              updateContact(contact);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
                  IconButton(icon: const Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Contact'),
                              content: Text(
                                  'Are you sure you want to delete ${contact.displayName}?'
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('CANCEL'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                TextButton(
                                  child: const Text('DELETE'),
                                  onPressed: () {
                                    deleteContact(contact);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          });
                    },
                  ),
                ],
              ),
            );
          }),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            Contact contacts = await ContactsService.openContactForm();
            if (contacts != null) {
              _fetchContacts();
            }
          } on FormOperationException catch(e){
            switch(e.errorCode){
              case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
              case FormOperationErrorCode.FORM_OPERATION_CANCELED:
              case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
                print(e.toString());

            }
          }
        },
        child: const Icon(Icons.add),
        elevation: 0.0,
      ),
    );
  }
}

//await ContactsService.deleteContact(contact);
//setState(() {

//contacts.remove(contact);

//});