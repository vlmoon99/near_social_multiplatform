import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:math';
import 'dart:typed_data';
// import 'package:typings/core.dart' as js;

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RoomScreen extends StatefulWidget {
  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8080'),
  );
  late Timer timer;
  String message = "";
  final random = Random();

  void printVec(JSArrayBuffer vec) {
    ByteBuffer buffer = vec.toDart;
    print(buffer.asInt8List().toList());
  }

  Future<void> startHeadlessAudioStream() async {
    try {
      print('Headless audio streaming started!');
    } catch (e) {
      print('Error starting headless audio stream: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    startHeadlessAudioStream();
    setupWebSocketStream();
  }

  void setupWebSocketStream() async {
    // Listen for messages from the server
    channel.stream.listen((msg) {
      setState(() {
        message = msg.toString();
      });
    });

    // Send a random 2D vector every second
    timer = Timer.periodic(Duration(milliseconds: 50), (_) {
      // Initialize the random number generator
      final Random random = Random();

      // Define the target size in bytes
      const int targetSizeInBytes = 100000;

      // Create an empty list to hold our data
      List<int> randomDataList = [];

      // Generate random bytes until we reach the target size
      while (randomDataList.length * 4 < targetSizeInBytes) {
        // Generate a random byte (0 to 255)
        int randomByte = random.nextInt(256);

        // Add it to our list
        randomDataList.add(randomByte);
      }

      // Check the size of the list
      print('Generated list size in bytes: ${randomDataList.length * 4}');

      channel.sink.add(jsonEncode(randomDataList));
    });
  }

  @override
  void dispose() {
    timer.cancel();
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Room')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return ListTile(title: Text(message));
              },
            ),
          ),
        ],
      ),
    );
  }
}
