import 'dart:convert';
import 'dart:math';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_social_mobile/modules/home/apis/models/encryption_keypair.dart';
import 'package:near_social_mobile/modules/home/apis/near_social.dart';
import 'package:rxdart/rxdart.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    Key? key,
    required this.room,
    required this.currentUser,
    required this.isSecure,
    required this.otherUser,
  }) : super(key: key);
  final bool isSecure;
  final types.Room room;
  final types.User currentUser;
  final types.User otherUser;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final BehaviorSubject<types.Room?> roomSubject =
      BehaviorSubject<types.Room?>();
  final BehaviorSubject<EncryptionKeypair?> sessionKeys =
      BehaviorSubject<EncryptionKeypair?>();
  final BehaviorSubject<List<types.Message>> messagesStream =
      BehaviorSubject<List<types.Message>>()..add([]);
  final BehaviorSubject<bool> isLoadingStream = BehaviorSubject<bool>()
    ..add(false);

  @override
  void initState() {
    super.initState();
    listenToRoom(widget.room.id);
    initChatFunctionality();
    FirebaseChatCore.instance.messages(widget.room).listen((messages) async {
      if (!widget.isSecure) {
        messagesStream.add(messages);
      } else {
        await initMessages(messages);
      }
    });
  }

  Future<void> initMessages(List<types.Message> messages) async {
    final keys = await CryptoHelper.getKeysFromSecureDB(widget.room.id);
    if (!sessionKeys.hasValue) {
      sessionKeys.add(keys);
    }
    if (keys != null) {
      List<types.Message> decdryptedChatMessages = [];
      List<Future<String>> decryptedMessagesFutures = messages.mapIndexed(
        (i, e) {
          return CryptoHelper.decryptMessage(
              keys.privateKey,
              e.metadata!["${widget.currentUser.id}:encryptedMessage"]
                  .toString());
        },
      ).toList();

      final decryptedMessages = await Future.wait(decryptedMessagesFutures);

      if (decryptedMessages.length < messages.length) {
        decdryptedChatMessages = messages
            .sublist(0, messages.length - 1)
            .mapIndexed((index, message) => (message as types.TextMessage)
                .copyWith(text: decryptedMessages[index]))
            .toList();
      } else {
        decdryptedChatMessages = messages
            .mapIndexed((index, message) => (message as types.TextMessage)
                .copyWith(text: decryptedMessages[index]))
            .toList();
      }
      messagesStream.add(decdryptedChatMessages);
    }
  }

  Future<void> initChatFunctionality() async {
    final isChatSecure = widget.isSecure;

    if (!isChatSecure) {
      return;
    }

    final pubKeyOfCurrentAccountId =
        widget.room.metadata?["${widget.currentUser.id}:pub_key"]?.toString() ??
            'no_pub_key';
    final chatMetadata = widget.room.metadata ?? {};
    final chatEncryptionsKeys =
        (chatMetadata['encryptionKeys'] as List<dynamic>?)
                ?.map((val) => val.toString())
                .toList() ??
            [];

    if (pubKeyOfCurrentAccountId == "no_pub_key") {
      final keys =
          await CryptoHelper.generateEncryptionKeysForRoom(widget.room.id);

      chatMetadata["${widget.currentUser.id}:pub_key"] = keys.publicKey;

      chatEncryptionsKeys.add(keys.publicKey);

      chatMetadata['encryptionKeys'] = chatEncryptionsKeys;

      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.room.id)
          .set(
            {'metadata': chatMetadata},
            SetOptions(merge: true),
          )
          .then(
              (value) => print("Metadata update , userKey inside secure room"))
          .catchError((error) => print("Failed to Metadata update: $error"));

      sessionKeys.add(keys);
    } else {
      final keyPair = await CryptoHelper.getKeysFromSecureDB(widget.room.id);

      if (keyPair == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "The keys can't be generated because this chat was first registered on a different device.",
            ),
          ),
        );
      }

      if (pubKeyOfCurrentAccountId == keyPair?.publicKey) {
        sessionKeys.add(keyPair);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "The keys can't be generated because this chat was first registered on a different device.",
            ),
          ),
        );
      }
    }
  }

Future<void> deleteRoom(String roomId, String uuid,bool isSecure) async {
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('deleteRoom');

      final response = await callable.call(<String, dynamic>{
        'roomId': roomId,
        'uuid': uuid,
        'isSecure': isSecure,
      });

      if (response.data['success'] == true) {
        print('Room deleted successfully: ${response.data['message']}');
      }
    } catch (e) {
      print('Failed to delete room: $e');
    }
  }

  Future<void> sendMessage(types.PartialText data, types.Room room) async {
    final listOfPubKeys = (room.metadata?['encryptionKeys'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final isThereMoreThanOnePublicKeyInside = listOfPubKeys.length > 1;

    if (!widget.isSecure) {
      Modular.get<NearSocialApi>()
          .sendMessage(data, room.id, widget.currentUser.id);
    } else if (!isThereMoreThanOnePublicKeyInside && widget.isSecure) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Your conversation partner must add his keys to this chat",
          ),
        ),
      );
    } else if (sessionKeys.hasValue &&
        sessionKeys.value != null &&
        isThereMoreThanOnePublicKeyInside) {
      if (data.metadata == null) {
        final newMessage = types.PartialText(text: "Encrypted", metadata: {});
        final usersInsideRoom = room.metadata!.entries
            .where((entry) => entry.key.contains(":pub_key"))
            .map((entry) => entry)
            .toList();

        for (MapEntry<String, dynamic> userEntry in usersInsideRoom) {
          final pubKey = userEntry.value;
          final accountId = userEntry.key.split(":");
          final encryptedText =
              await CryptoHelper.encryptMessage(pubKey, data.text);
          newMessage.metadata!["${accountId.first}:encryptedMessage"] =
              encryptedText;
        }

        Modular.get<NearSocialApi>()
            .sendMessage(newMessage, room.id, widget.currentUser.id);
      } else {
        data.metadata!["${widget.currentUser.id}:encryptedMessage"];
        Modular.get<NearSocialApi>()
            .sendMessage(data, room.id, widget.currentUser.id);
      }
    } else if (sessionKeys.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "There no keys to encrypt message",
          ),
        ),
      );
    }
  }

  void listenToRoom(String roomId) {
    FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final roomData = snapshot.data()!;
        roomSubject.add(transformRoomData(roomId, roomData));
      } else {
        roomSubject.add(widget.room);
      }
    });
  }

  types.Room transformRoomData(String roomId, Map<String, dynamic> roomData) {
    return types.Room(
      createdAt: (roomData['createdAt'] as Timestamp?)?.millisecondsSinceEpoch,
      id: roomId,
      imageUrl: roomData['imageUrl'] as String?,
      lastMessages: (roomData['lastMessages'] as List<dynamic>?)
          ?.map((message) => types.Message.fromJson(message))
          .toList(),
      metadata: roomData['metadata'] as Map<String, dynamic>?,
      name: roomData['name'] as String?,
      type: roomData['type'] != null
          ? types.RoomType.values.firstWhere(
              (type) => type.toString() == 'RoomType.${roomData['type']}')
          : null,
      updatedAt:
          (roomData['updatedAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0,
      users: (roomData['users'] as List<dynamic>?)
              ?.map((user) => types.User.fromJson(user))
              .toList() ??
          <types.User>[],
    );
  }

  @override
  void dispose() {
    super.dispose();
    // roomSubject.close();
    // sessionKeys.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.isSecure ? "Secure Chat" : "Chat"),
        actions: [
          IconButton(
            onPressed: () async {


              if (widget.isSecure) {
                await CryptoHelper.deleteEncryptionKeysForRoom(widget.room.id);
                await deleteRoom(
                    widget.room.id, FirebaseAuth.instance.currentUser!.uid,true);
              } else {
                await deleteRoom(
                    widget.room.id, FirebaseAuth.instance.currentUser!.uid,false);
              }

              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
          StreamBuilder<bool>(
              stream: isLoadingStream,
              builder: (context, snapshot) {
                final isLoading = snapshot.data ?? false;
                if (isLoading) {
                  // ignore: prefer_const_constructors
                  return CircularProgressIndicator.adaptive();
                }
                return !widget.isSecure && !isLoading
                    ? IconButton(
                        onPressed: () async {
                          if (!widget.isSecure) {
                            isLoadingStream.add(true);
                            final room = await Modular.get<NearSocialApi>()
                                .createChatRoom(
                                    true, widget.currentUser, widget.otherUser,
                                    metadata: {"isSecure": true});
                            isLoadingStream.add(false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => ChatPage(
                                  room: room!,
                                  currentUser: widget.currentUser,
                                  otherUser: widget.otherUser,
                                  isSecure: true,
                                ),
                              ),
                            );
                          }
                        },
                        icon: Icon(
                          Icons.security,
                          color:
                              widget.isSecure ? Colors.lightBlue : Colors.grey,
                        ),
                      )
                    : IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.key),
                      );
              }),
        ],
        leading: IconButton(
          onPressed: () {
            print("Icons.backspace");
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: StreamBuilder(
        stream: roomSubject,
        initialData: widget.room,
        builder: (context, snapshot) {
          final room = snapshot.data!;
          return StreamBuilder<List<types.Message>>(
            initialData: [],
            stream: messagesStream,
            builder: (context, messagesSnapshot) {
              return Chat(
                scrollPhysics: const BouncingScrollPhysics(),
                messages: messagesSnapshot.data ?? [],
                onSendPressed: (data) async {
                  sendMessage(data, room);
                },
                user: widget.currentUser,
              );
            },
          );
        },
      ),
    );
  }
}

class CryptoHelper {
  static Future<String> decryptMessage(
      String privateKey, String encryptedMessage) async {
    final decryptedMessage = await Modular.get<NearSocialApi>()
        .nearBlockChainService
        .jsVMService
        .callJS("""
        let privateKey = `$privateKey`;
        let encryptedMessage = `$encryptedMessage`;

        let decryptedMessage = window.decrypt_message(privateKey,encryptedMessage)
     
        decryptedMessage
        """);

    return decryptedMessage.toString();
  }

  static Future<String> encryptMessage(String publicKey, String message) async {
    final encryptedMessage = await Modular.get<NearSocialApi>()
        .nearBlockChainService
        .jsVMService
        .callJS("""
        let publicKey = `$publicKey`;
        let message = `$message`;

        let encryptedMessage = window.encrypt_message(publicKey,message)
     
        encryptedMessage
        """);

    return encryptedMessage.toString();
  }

  static Future<EncryptionKeypair> generateKeyPair() async {
    final keyPairs = await Modular.get<NearSocialApi>()
        .nearBlockChainService
        .jsVMService
        .callJS("""
        let keypair = window.generate_keypair()

        function getParsedKey() {
        
          return { "privateKey" : keypair.private_key , "publicKey" : keypair.public_key }
        
        }

        JSON.stringify(getParsedKey())
        """);

    final data = jsonDecode(keyPairs);
    return EncryptionKeypair.fromJson(data);
  }

  static Future<EncryptionKeypair> generateEncryptionKeysForRoom(
      String roomId) async {
    final keys = await generateKeyPair();

    await const FlutterSecureStorage()
        .write(key: roomId, value: jsonEncode(keys));

    return keys;
  }

  static Future<void> deleteEncryptionKeysForRoom(String roomId) async {
    await const FlutterSecureStorage().delete(key: roomId);
  }

  static Future<EncryptionKeypair?> getKeysFromSecureDB(String roomId) async {
    final encodedKeys = await const FlutterSecureStorage().read(key: roomId);
    if (encodedKeys == null) return null;

    final decodedKeys = EncryptionKeypair.fromJson(jsonDecode(encodedKeys));

    return decodedKeys;
  }
}
