import 'package:equatable/equatable.dart';

class UserStorageInfo extends Equatable {
  final int? usedBytes;
  final int? availableBytes;

  const UserStorageInfo({
    required this.usedBytes,
    required this.availableBytes,
  });

  @override
  List<Object?> get props => [usedBytes, availableBytes];
  @override
  bool? get stringify => true;
}