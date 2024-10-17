import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_event_listener.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_user.dart';
import 'package:gtask/jwt_service.dart';
import 'package:events_emitter/events_emitter.dart';
import 'package:image_picker/image_picker.dart';


class ZoomPage extends StatefulWidget {
  const ZoomPage({super.key});

  @override
  State<ZoomPage> createState() => _ZoomPageState();
}

class _ZoomPageState extends State<ZoomPage> {
  var zoom = ZoomVideoSdk();
  var eventListener = ZoomVideoSdkEventListener();

  @override 
  void initState() {
    super.initState();
    setupListeners();
  }

  void setupListeners() {
    eventListener.addEventListener();
    EventEmitter emitter = eventListener.eventEmitter;

    final sessionJoinListener =
          emitter.on(EventType.onSessionJoin, (sessionUser) async {
        // Handle the session join event
        //await _joinSession(sessionUser);
        print("Listener Triggered");
        ZoomVideoSdkUser mySelf =
            ZoomVideoSdkUser.fromJson(jsonDecode(sessionUser.toString()));
        List<ZoomVideoSdkUser>? remoteUsers =
            await zoom.session.getRemoteUsers();
      });
  }

  void openCamera() async {
  final ImagePicker _picker = ImagePicker();
  final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
  
  if (photo != null) {
    // Do something with the captured image
    print("Camera opened and image captured: ${photo.path}");
  } else {
    print("Camera opened but no image was captured.");
  }
}

  Future<void> _joinSession(String sessionName, String sessionPassword, String displayName, String role) async {
    // // Replace these with your actual values or pass them from the dialog
    // String sessionName = 'name of the video session'; // You can retrieve this from the dialog if needed
    // String sessionPassword = 'session password if have one'; // Same as above
     String token = generateJwt(sessionName, role); // You can retrieve the role dynamically
    // String displayName = 'name of user'; // You can retrieve this from the dialog if needed

    Map<String, bool> audioOptions = {
      "connect": true, 
      "mute": true
    };
    Map<String, bool> videoOptions = {
      "localVideoOn": true,
    };

    JoinSessionConfig joinSession = JoinSessionConfig(
      sessionName: sessionName,
      sessionPassword: sessionPassword,
      token: token,
      userName: displayName,
      audioOptions: audioOptions,
      videoOptions: videoOptions,
    );

    try {
      await zoom.joinSession(joinSession);
      openCamera();
      print("Joined session successfully.");


    } catch (e) {
      print('Error joining session: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showJoinDialog() {
    final TextEditingController sessionNameController = TextEditingController();
    final TextEditingController sessionPasswordController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController roleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Join Zoom Session"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: sessionNameController,
                  decoration: const InputDecoration(labelText: "Session Name"),
                ),
                TextField(
                  controller: sessionPasswordController,
                  decoration: const InputDecoration(labelText: "Session Password"),
                  obscureText: true,
                ),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: "Display Name"),
                ),
                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(labelText: "Role"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Call _joinSession with parameters from the dialog
                _joinSession(
                  //  sessionNameController.text
                  sessionNameController.text,
                  sessionPasswordController.text,
                  usernameController.text,
                  roleController.text,
                );
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Join'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: GestureDetector(
          onTap: _showJoinDialog,
          child: Container(
            height: 50,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(child: Text('Join Zoom')),
          ),
        ),
      ),
    );
  }
}
