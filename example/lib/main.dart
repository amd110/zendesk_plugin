import 'package:flutter/material.dart';
import 'package:zendesk_plugin_plus/zendesk_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initZendesk();
  }

  Future<void> initZendesk() async {
    if (!mounted) {
      return;
    }
    await Zendesk.initialize('', '');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Zendesk Chat Plugin'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Initialize  example with proper\nkeys in main.dart',
                  textAlign: TextAlign.center,
                ),
              ),
              MaterialButton(
                onPressed: openChat,
                color: Colors.blueGrey,
                textColor: Colors.white,
                child: const Text('Open Chat'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> openChat() async {
    try {
      await Zendesk.setVisitorInfo(
          name: 'Text Client',
          email: 'test+client@example.com',
          phoneNumber: '0000000000',
          department: 'Support');
      await Zendesk.startChat();
    } on dynamic catch (ex) {
      print('An error occured $ex');
    }
  }
}
