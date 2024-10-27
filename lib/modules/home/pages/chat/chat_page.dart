import 'dart:convert';
import 'dart:math';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutterchain/flutterchain_lib.dart';
import 'package:flutterchain/flutterchain_lib/repositories/wallet_repository.dart';
import 'package:near_social_mobile/modules/home/apis/models/encryption_keypair.dart';
import 'package:near_social_mobile/modules/home/apis/near_social.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:rxdart/rxdart.dart';

import 'package:encrypt/encrypt.dart' as encrypt;

import 'dart:typed_data';
import 'package:pointycastle/export.dart' as crypto;

class ChatPage extends StatefulWidget {
  const ChatPage({
    Key? key,
    required this.room,
    required this.currentUser,
    required this.isSecure,
  }) : super(key: key);
  final bool isSecure;
  final types.Room room;
  final types.User currentUser;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final BehaviorSubject<types.Room?> roomSubject =
      BehaviorSubject<types.Room?>();
  final BehaviorSubject<EncryptionKeypair?> sessionKeys =
      BehaviorSubject<EncryptionKeypair?>();
  final BehaviorSubject<List<types.Message>> messagesStream =
      BehaviorSubject<List<types.Message>>();
  final enCryptedChatKey = ValueKey("enCryptedChatKey");
  final deCryptedChatKey = ValueKey("deCryptedChatKey");

  @override
  void initState() {
    super.initState();
    listenToRoom(widget.room.id);
    initChatFunctionality();
    FirebaseChatCore.instance.messages(widget.room).listen((messages) async {
      if (!widget.isSecure) {
        messagesStream.add(messages);
      } else {
        List<types.Message> decdryptedChatMessages = [];
        List<Future<String>> decryptedMessagesFutures = messages.mapIndexed(
              (i, e) {
                return CryptoHelper.decryptMessage(
                    sessionKeys.value!.privateKey,
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
    });
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
        (widget.room.metadata!['encryptionKeys'] as List<String>?) ?? [];

    if (pubKeyOfCurrentAccountId == "no_pub_key") {
      final keys =
          await CryptoHelper.generateEncryptionKeysForRoom(widget.room.id);

      chatMetadata["${widget.currentUser.id}:pub_key"] = keys.publicKey;

      chatEncryptionsKeys.add(keys.publicKey);

      chatMetadata['encryptionKeys'] = chatEncryptionsKeys;

      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.room.id)
          .set({'metadata': chatMetadata})
          .then(
              (value) => print("Metadata update , userKey inside secure room"))
          .catchError((error) => print("Failed to add user: $error"));

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

        if (pubKeyOfCurrentAccountId == keyPair!.publicKey) {
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

  @override
  void dispose() {
    super.dispose();
    roomSubject.close();
    sessionKeys.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.isSecure ? "Secure Chat" : "Chat"),
        actions: [
          !widget.isSecure
              ? IconButton(
                  onPressed: () async {
                    if (!widget.isSecure) {
                      final accountIds = <String>[];
                      final users = <types.User>[];

                      for (types.User user in widget.room.users) {
                        final userInfo = await Modular.get<NearSocialApi>()
                            .getGeneralAccountInfo(accountId: user.id);
                        accountIds.add(userInfo.accountId);
                      }

                      for (String accountId in accountIds) {
                        final userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(accountId)
                            .get();

                        if (userDoc.exists) {
                          final userData = {
                            "id": userDoc.id,
                            "imageUrl": userDoc.data()!['imageUrl'],
                            "firstName": userDoc.data()!['firstName'],
                            "lastName": userDoc.data()!['lastName'],
                            "role": userDoc.data()!['role'],
                            "metadata": userDoc.data()!['metadata'],
                          };

                          final user = types.User.fromJson(userData);
                          users.add(user);
                        }
                      }

                      final room =
                          await Modular.get<NearSocialApi>().createRoom(
                        true,
                        Modular.get<AuthController>().state.accountId,
                        users.first,
                        metadata: {'isSecure': true},
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => ChatPage(
                            room: room,
                            currentUser: widget.currentUser,
                            isSecure: true,
                          ),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.security,
                    color: widget.isSecure ? Colors.lightBlue : Colors.grey,
                  ),
                )
              : IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.key),
                ),
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

  Future<void> sendMessage(types.PartialText data, types.Room room) async {
    if (!widget.isSecure) {
      Modular.get<NearSocialApi>()
          .sendMessage(data, room.id, widget.currentUser.id);
    } else if (sessionKeys.hasValue && sessionKeys.value != null) {
      final keys = sessionKeys.value!;
      if (data.metadata == null) {
        final listOfPubKeys =
            (room.metadata?['encryptionKeys'] as List<dynamic>)
                .map((e) => e.toString())
                .toList();

        final newMessage = types.PartialText(text: "Encrypted", metadata: {});

        for (String key in listOfPubKeys) {
          final encryptedText = await CryptoHelper.encryptMessage(
              sessionKeys.value!.publicKey, data.text);
          newMessage.metadata!["${widget.currentUser.id}:encryptedMessage"] =
              encryptedText;
        }

        Modular.get<NearSocialApi>()
            .sendMessage(newMessage, room.id, widget.currentUser.id);
      } else {
        data.metadata!["${widget.currentUser.id}:encryptedMessage"];
        Modular.get<NearSocialApi>()
            .sendMessage(data, room.id, widget.currentUser.id);
      }

      //send encypted message
    } else if (sessionKeys.value == null) {
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

  static Future<EncryptionKeypair?> getKeysFromSecureDB(String roomId) async {
    final encodedKeys = await const FlutterSecureStorage().read(key: roomId);
    if (encodedKeys == null) return null;

    final decodedKeys = EncryptionKeypair.fromJson(jsonDecode(encodedKeys));

    return decodedKeys;
  }
}
