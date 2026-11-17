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
              ),
              // 结束当前正在进行的会话
              MaterialButton(
                onPressed: endChat,
                color: Colors.blueGrey,
                textColor: Colors.white,
                child: const Text('End Chat'),
              ),
              // 清除访客信息并重置身份(通常在用户退出登录时调用)
              MaterialButton(
                onPressed: clearVisitorInfo,
                color: Colors.blueGrey,
                textColor: Colors.white,
                child: const Text('Clear Visitor Info'),
              ),
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
    } catch (ex) {
      print('An error occured $ex');
    }
  }

  /// 结束当前正在进行的会话
  Future<void> endChat() async {
    try {
      await Zendesk.endChat();
    } catch (ex) {
      print('An error occured $ex');
    }
  }

  /// 清除访客信息(姓名、邮箱、手机号、部门)并重置访客身份
  Future<void> clearVisitorInfo() async {
    try {
      await Zendesk.clearVisitorInfo();
    } catch (ex) {
      print('An error occured $ex');
    }
  }
}
