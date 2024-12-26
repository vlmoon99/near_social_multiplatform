import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

@JS()
external set captureMicrophone(JSFunction value);

class RoomScreen extends StatefulWidget {
  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8080'),
  );
  late Timer timer;
  List<String> messages = [];
  final random = Random();

  void printVec(JSArrayBuffer vec) {
    ByteBuffer buffer = vec.toDart;
    print(buffer.asInt8List().toList());
  }

  Future<void> startHeadlessAudioStream() async {
    try {
      captureMicrophone = printVec.toJS;
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
    channel.stream.listen((message) {
      setState(() {
        messages.add(message);
      });
    });

    // Send a random 2D vector every second
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      final vector = {
        'x': random.nextDouble() * 100,
        'y': random.nextDouble() * 100,
      };
      channel.sink.add(jsonEncode(vector));
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
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(messages[index]));
              },
            ),
          ),
        ],
      ),
    );
  }
}
