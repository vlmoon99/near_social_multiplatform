class User {
  final String name;
  final String accountId;
  final String photo;

  User({required this.name, required this.accountId, required this.photo});

  User copyWith({String? name, String? accountId, String? photo}) {
    return User(
      name: name ?? this.name,
      accountId: accountId ?? this.accountId,
      photo: photo ?? this.photo,
    );
  }

  @override
  String toString() {
    return 'Chat(name: $name , accountId :$accountId , photo : $photo )';
  }
}
