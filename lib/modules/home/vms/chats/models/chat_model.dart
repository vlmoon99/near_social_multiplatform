import 'package:flutter/material.dart';

enum ChatType {
  // publicUserToUser(
  //   label: 'Public',
  //   icon: Icons.public,
  // ),
  privateUserToUser(
    label: 'Private',
    icon: Icons.lock_outline,
  );
  // group(
  //   label: 'Group',
  //   icon: Icons.group,
  // ),
  // ai(
  //   label: 'AI Chat',
  //   icon: Icons.smart_toy_outlined,
  // )

  final String label;
  final IconData icon;

  const ChatType({
    required this.label,
    required this.icon,
  });
}

class Chat {
  final String name;
  final String imagePath;
  final bool isPublic;

  Chat({required this.name, required this.imagePath, required this.isPublic});

  Chat copyWith({String? name, String? imagePath, bool? isPublic}) {
    return Chat(
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  @override
  String toString() {
    return 'Chat(name: $name , imagePath :$imagePath , isPublic : $isPublic )';
  }
}
