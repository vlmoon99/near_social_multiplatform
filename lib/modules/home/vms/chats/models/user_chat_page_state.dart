class UserChatPageState {
  final bool isSearching;

  UserChatPageState({required this.isSearching});

  UserChatPageState copyWith({bool? isSearching}) {
    return UserChatPageState(
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  String toString() {
    return 'UserChatPageState(isSearching: $isSearching)';
  }
}
