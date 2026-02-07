import 'package:equatable/equatable.dart';

class P2PConnectionStats extends Equatable {
  final String connectionType;
  final String protocol;
  final String localAddress;
  final String remoteAddress;
  final int packetsLost;
  final String connectionState;

  const P2PConnectionStats({
    required this.connectionType,
    required this.protocol,
    required this.localAddress,
    required this.remoteAddress,
    required this.packetsLost,
    required this.connectionState,
  });

  @override
  List<Object?> get props => [
        connectionType,
        protocol,
        localAddress,
        remoteAddress,
        packetsLost,
        connectionState,
      ];
}
