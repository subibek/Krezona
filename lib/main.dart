import 'package:flutter/material.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:gtask/zoom.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  InitConfig initConfig = InitConfig(
    domain: "zoom.us",
    enableLog: true,
  );

  var zoom = ZoomVideoSdk();

  try {
    await zoom.initSdk(initConfig);
  } catch (e) {
    print('Error initializing Zoom SDK: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: ZoomPage(),
    );
  }
}
