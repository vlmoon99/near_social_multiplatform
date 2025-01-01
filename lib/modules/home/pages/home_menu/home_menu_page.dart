import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterchain/flutterchain_lib/models/chains/near/near_account_info_request.dart';
import 'package:flutterchain/flutterchain_lib/services/chains/near_blockchain_service.dart';
import 'package:near_social_mobile/config/constants.dart';
import 'package:near_social_mobile/config/theme.dart';
import 'package:near_social_mobile/modules/home/apis/models/user_storage_info.dart';
import 'package:near_social_mobile/modules/home/apis/near_social.dart';
import 'package:near_social_mobile/modules/home/pages/home_menu/widgets/home_menu_list_tile.dart';
import 'package:near_social_mobile/modules/home/vms/users/models/user_list_state.dart';
import 'package:near_social_mobile/modules/home/vms/users/user_list_controller.dart';
import 'package:near_social_mobile/modules/vms/core/auth_controller.dart';
import 'package:near_social_mobile/routes/routes.dart';
import 'package:near_social_mobile/shared_widgets/custom_button.dart';
import 'package:near_social_mobile/shared_widgets/near_network_image.dart';
import 'package:near_social_mobile/shared_widgets/spinner_loading_indicator.dart';
import 'package:near_social_mobile/shared_widgets/storage_controll_dialogs.dart';

class HomeMenuPage extends StatelessWidget {
  const HomeMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ProfileBanner(),
          SizedBox(height: 10.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20).r,
            child: Column(
              children: [
                HomeMenuListTile(
                  tile: SvgPicture.asset(
                    "assets/media/icons/nft-token.svg",
                    color: IconTheme.of(context).color,
                    height: IconTheme.of(context).size,
                  ),
                  title: "Mintbase Manager",
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Modular.to.pushNamed(
                      ".${Routes.home.mintManager}/",
                    );
                  },
                ),
                HomeMenuListTile(
                  tile: const Icon(Icons.message),
                  title: "Chats",
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Modular.to.pushNamed(
                      ".${Routes.home.chatsPage}",
                    );
                  },
                ),
                HomeMenuListTile(
                  tile: const Icon(Icons.feed),
                  title: "Smart Posts",
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Modular.to.pushNamed(".${Routes.home.smartFeedPage}");
                  },
                ),
                HomeMenuListTile(
                  tile: const Icon(Icons.settings),
                  title: "Settings",
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Modular.to.pushNamed(
                      ".${Routes.home.settingsPage}",
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileBanner extends StatefulWidget {
  const ProfileBanner({
    super.key,
  });

  @override
  State<ProfileBanner> createState() => _ProfileBannerState();
}

class _ProfileBannerState extends State<ProfileBanner> {
  final AuthController authController = Modular.get<AuthController>();
  final UserListController userListController =
      Modular.get<UserListController>();
  late FullUserInfo user;
  String? balance;
  UserStorageInfo? storageInfo;
  bool loading = true;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (loading) {
      await userListController.loadAndAddGeneralAccountInfoIfNotExists(
          accountId: authController.state.accountId);
      setState(() {
        user = userListController.state
            .getUserByAccountId(accountId: authController.state.accountId);
        loading = false;
      });
      if (balance == null) {
        Modular.get<NearBlockChainService>()
            .getWalletBalance(NearAccountInfoRequest(
                accountId: authController.state.accountId))
            .then(
          (value) {
            setState(() {
              balance = value;
            });
          },
        );
      }
      if (storageInfo == null) {
        Modular.get<NearSocialApi>()
            .getUserStorageInfo(authController.state.accountId)
            .then(
          (value) {
            setState(() {
              storageInfo = value;
            });
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? SizedBox(
            height: .3.sh,
            child: const Center(
              child: SpinnerLoadingIndicator(),
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: .25.sh,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    SizedBox(
                      height: .20.sh,
                      width: double.infinity,
                      child: NearNetworkImage(
                        imageUrl: user.generalAccountInfo.backgroundImageLink,
                        errorPlaceholder:
                            Container(color: AppColors.lightSurface),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 20.h,
                      width: .18.sh,
                      height: .18.sh,
                      child: Container(
                        padding: REdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: NearNetworkImage(
                            imageUrl: user.generalAccountInfo.profileImageLink,
                            errorPlaceholder: Image.asset(
                              NearAssets.standartAvatar,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20).r,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.generalAccountInfo.name != ""
                          ? user.generalAccountInfo.name
                          : "No Name",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.person_fill,
                          size: 14,
                        ),
                        SizedBox(width: 5.h),
                        Expanded(
                          child: MediaQuery.sizeOf(context).width < 600
                              ? GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    Clipboard.setData(
                                      ClipboardData(
                                        text: user.generalAccountInfo.accountId,
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "AccountId ${user.generalAccountInfo.accountId} copied to clipboard"),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "@${user.generalAccountInfo.accountId}",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                )
                              : SelectableText(
                                  "@${user.generalAccountInfo.accountId}",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        const Text(
                          "Balance: ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5.h),
                        if (balance == null)
                          AnimatedTextKit(
                            animatedTexts: [
                              FadeAnimatedText('Loading...'),
                            ],
                            isRepeatingAnimation: true,
                            repeatForever: true,
                          )
                        else
                          Expanded(
                            child: Text(
                              "$balance NEAR",
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        const Text(
                          "Storage space: ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5.h),
                        if (storageInfo == null) ...[
                          AnimatedTextKit(
                            animatedTexts: [
                              FadeAnimatedText('Loading...'),
                            ],
                            isRepeatingAnimation: true,
                            repeatForever: true,
                          )
                        ] else ...[
                          Text(
                            "${((storageInfo?.availableBytes ?? 0) / 1000).toStringAsFixed(2)} kb",
                          ),
                          // SizedBox(width: 10.w),
                          Spacer(),
                          SizedBox(
                            height: 30.h,
                            child: CustomButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return WithdrawStorageDialog();
                                  },
                                );
                              },
                              child: Text("Withdraw"),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}
