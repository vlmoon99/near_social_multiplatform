sealed class SettingsEvent {}

class LoadFiltersEvent extends SettingsEvent {}

class BlockUserEvent extends SettingsEvent {
  final String accountId;
  final String blockedAccountId;
  BlockUserEvent({required this.accountId, required this.blockedAccountId});
}

class UnblockUserEvent extends SettingsEvent {
  final String accountId;
  final String blockedAccountId;
  UnblockUserEvent({required this.accountId, required this.blockedAccountId});
}

class HidePostEvent extends SettingsEvent {
  final String accountId;
  final String accountIdToHide;
  final int blockHeightToHide;
  HidePostEvent({
    required this.accountId,
    required this.accountIdToHide,
    required this.blockHeightToHide,
  });
}

class HidePostsOfUserEvent extends SettingsEvent {
  final String accountId;
  final String accountIdToHide;
  HidePostsOfUserEvent({required this.accountId, required this.accountIdToHide});
}

class RestorePostsOfUserEvent extends SettingsEvent {
  final String accountId;
  final String accountIdToRestore;
  RestorePostsOfUserEvent({required this.accountId, required this.accountIdToRestore});
}

class ClearFiltersEvent extends SettingsEvent {}
