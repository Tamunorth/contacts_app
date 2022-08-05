import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Contact> contacts = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: _scaffoldKey,
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  height: 50.0,
                  width: 50.0,
                ),
                Text('text'),
                SizedBox(
                  height: 50.0,
                  width: 50.0,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                    child: Text('Gen contacts'),
                    onPressed: () async {
                      List.generate(10, (index) async {
                        final newContact = Contact()
                          ..name.first = 'John $index'
                          ..name.last = 'Smith $index'
                          ..displayName = 'Tams Made $index'
                          ..phones = [Phone('555-123-456$index')];
                        await newContact.insert();
                      });
                    }),
              ],
            ),
            SizedBox(height: 50.0),
            Consumer(
              builder: (context, ref, child) {
                var state = ref.watch(contactsProvider);

                final snackBar = SnackBar(
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.yellow,
                  content: Text('updating cart....'),
                );
                final snackBar2 = SnackBar(
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.yellow,
                  content: Text('update'),
                );

                ref.listen(contactsProvider, (previous, next) {
                  state.status == ContactStatus.loading
                      ? ScaffoldMessenger.of(context).showSnackBar(snackBar)
                      : ScaffoldMessenger.of(context).showSnackBar(snackBar2);
                });

                return state.status == ContactStatus.empty
                    ? Text('Empty')
                    : state.status == ContactStatus.loading
                        ? Center(child: CircularProgressIndicator())
                        : SizedBox(
                            height: 500.0,
                            child: ListView.builder(
                              itemCount: state.details?.length,
                              itemBuilder: (context, index) =>
                                  Text(state.details?[index].displayName ?? ''),
                            ),
                          );
              },
            ),
            Consumer(
              builder: (context, ref, child) {
                return FloatingActionButton(onPressed: () {
                  ref.read(contactsProvider.notifier).getContacts();
                });
              },
            )
          ],
        ),
      ),
    );
  }
}

enum ContactStatus {
  empty,
  loading,
  loaded,
}

class ContactsModel {
  ContactStatus status;
  List<Contact>? details;

  ContactsModel({required this.status, this.details});
}

final contactsProvider =
    StateNotifierProvider<ContactsNotifier, ContactsModel>((ref) {
  return ContactsNotifier();
});

class ContactsNotifier extends StateNotifier<ContactsModel> {
  ContactsNotifier()
      : super(ContactsModel(status: ContactStatus.empty, details: []));

  void getContacts() async {
    bool allowed = await FlutterContacts.requestPermission();
    if (allowed) {
      state = ContactsModel(status: ContactStatus.loading, details: []);

      await Future.delayed(Duration(seconds: 4));

      var contactList = await FlutterContacts.getContacts();

      state = ContactsModel(status: ContactStatus.loaded, details: contactList);
      log(state.details?.first.displayName ?? 'Empty');
    }
  }
}
