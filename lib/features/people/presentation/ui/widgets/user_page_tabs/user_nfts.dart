import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/features/people/data/models/nft.dart';
import 'package:near_social_mobile/features/people/presentation/providers/user_list_controller.dart';
import 'package:near_social_mobile/core/shared_widgets/image_full_screen_page.dart';
import 'package:near_social_mobile/core/shared_widgets/near_network_image.dart';
import 'package:near_social_mobile/core/shared_widgets/spinner_loading_indicator.dart';

class NftsView extends ConsumerStatefulWidget {
  const NftsView({super.key, required this.accountIdOfUser});

  final String accountIdOfUser;

  @override
  ConsumerState<NftsView> createState() => _NftsViewState();
}

class _NftsViewState extends ConsumerState<NftsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final userListController = ref.read(userListControllerProvider.notifier);
        final user = ref.read(userListControllerProvider)
            .getUserByAccountId(accountId: widget.accountIdOfUser);
        if (user.nfts == null) {
          userListController
              .loadNftsOfAccount(accountId: widget.accountIdOfUser);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userListState = ref.watch(userListControllerProvider);
    final nfts = userListState
        .getUserByAccountId(accountId: widget.accountIdOfUser)
        .nfts;
    if (nfts == null) {
      return const Center(child: SpinnerLoadingIndicator());
    } else if (nfts.isEmpty) {
      return Center(child: Text("people.no_nfts".tr()));
    } else {
      return ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20).r,
        itemBuilder: (context, index) {
          return NftCard(nft: nfts[index]);
        },
        itemCount: nfts.length,
      );
    }
  }
}

class NftCard extends StatelessWidget {
  const NftCard({super.key, required this.nft});

  final Nft nft;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: REdgeInsets.all(10.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageFullScreen(
                      imageUrl: nft.imageUrl,
                    ),
                  ),
                );
              },
              child: Hero(
                tag: "${nft.contractId}${nft.tokenId}",
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 200.h,
                  ),
                  child: NearNetworkImage(
                    imageUrl: nft.imageUrl,
                    errorPlaceholder: const Icon(Icons.broken_image),
                  ),
                ),
              ),
            ),
            if (nft.title != "") Text(nft.title),
            if (nft.description == "") Text(nft.description),
          ],
        ),
      ),
    );
  }
}
