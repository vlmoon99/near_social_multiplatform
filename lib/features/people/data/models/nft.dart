import 'package:freezed_annotation/freezed_annotation.dart';

part 'nft.freezed.dart';

@freezed
abstract class Nft with _$Nft {
  const factory Nft({
    required String contractId,
    required String tokenId,
    required String title,
    required String description,
    required String imageUrl,
  }) = _Nft;
}
