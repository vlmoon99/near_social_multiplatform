import 'package:near_social_mobile/features/people/data/models/general_account_info.dart';

sealed class PeopleEvent {}

class LoadUsersEvent extends PeopleEvent {}

class AddUserEvent extends PeopleEvent {
  final GeneralAccountInfo generalAccountInfo;
  AddUserEvent({required this.generalAccountInfo});
}

class LoadAndAddUserEvent extends PeopleEvent {
  final String accountId;
  LoadAndAddUserEvent({required this.accountId});
}

class LoadAdditionalMetadataEvent extends PeopleEvent {
  final String accountId;
  LoadAdditionalMetadataEvent({required this.accountId});
}

class FollowAccountEvent extends PeopleEvent {
  final String accountIdToFollow;
  FollowAccountEvent({required this.accountIdToFollow});
}

class UnfollowAccountEvent extends PeopleEvent {
  final String accountIdToUnfollow;
  UnfollowAccountEvent({required this.accountIdToUnfollow});
}

class ReloadUserInfoEvent extends PeopleEvent {
  final String accountId;
  ReloadUserInfoEvent({required this.accountId});
}

class LoadNftsEvent extends PeopleEvent {
  final String accountId;
  LoadNftsEvent({required this.accountId});
}
