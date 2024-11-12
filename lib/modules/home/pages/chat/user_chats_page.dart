import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:near_social_mobile/modules/home/apis/near_social.dart';
import 'package:near_social_mobile/modules/home/pages/chat/chat_page.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class UserChatsPage extends StatefulWidget {
  const UserChatsPage({super.key});

  @override
  State<UserChatsPage> createState() => _UserChatsPageState();
}

class _UserChatsPageState extends State<UserChatsPage> {
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

  String getChatTitle(List<String> accountIds, bool isSecure) {
    String participants = accountIds.join(', ');

    String securityLabel = isSecure ? "(Secure)" : "(Public)";

    return "$participants $securityLabel";
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAccountId = Modular.get<AuthController>().state.accountId;
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Chats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .where('userIds', arrayContains: currentUserAccountId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            setState(() {});
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No chat rooms found.'));
          }

          final rooms = snapshot.data!.docs.map((doc) {
            return transformRoomData(
                doc.id, doc.data() as Map<String, dynamic>);
          }).toList();

          final titles = snapshot.data!.docs.map((doc) {
            return ((doc.data() as Map<String, dynamic>)['userIds']
                    as List<dynamic>)
                .toList()
                .map((val) => val.toString())
                .toList();
          }).toList();

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              final userIds = titles[index];
              final isSecure = room.metadata?['isSecure'] != null
                  ? room.metadata!['isSecure'] as bool
                  : false;

              return ListTile(
                title: Text(
                  getChatTitle(
                    userIds,
                    isSecure,
                  ),
                ),
                subtitle: Text(
                    'Last updated: ${DateTime.fromMillisecondsSinceEpoch(room.updatedAt ?? 0)}'),
                onTap: () async {
                  try {
                    final users = <types.User>[];

                    for (String accountId in userIds) {
                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(accountId)
                          .get();

                      final userData = {
                        "id": userDoc.id,
                        "imageUrl": userDoc.data()!['imageUrl'],
                        "firstName": userDoc.data()!['firstName'],
                        "lastName": userDoc.data()!['lastName'],
                        "role": userDoc.data()!['role'],
                        "metadata": userDoc.data()!['metadata'],
                      };

                      final otherUser = types.User.fromJson(userData);

                      users.add(otherUser);
                    }

                    final currentUser = users
                        .firstWhere((user) => user.id == currentUserAccountId);
                    final otherUser = users
                        .firstWhere((user) => user.id != currentUserAccountId);

                    final room =
                        await Modular.get<NearSocialApi>().createChatRoom(
                      isSecure,
                      users[0],
                      users[1],
                      metadata: {"isSecure": isSecure},
                    );

                    if (room != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => ChatPage(
                            isSecure: isSecure,
                            room: room,
                            currentUser: currentUser,
                            otherUser: otherUser,
                          ),
                        ),
                      );
                      print('Chat room created successfully with user: $room');
                    }
                  } catch (e) {
                    print('Error creating room: $e');
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
