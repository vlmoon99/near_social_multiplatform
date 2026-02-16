import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:near_social_mobile/core/config/animation_constants.dart';
import 'package:near_social_mobile/features/settings/presentation/ui/home_menu_page.dart';
import 'package:near_social_mobile/features/notifications/presentation/ui/notifications_modal.dart';
import 'package:near_social_mobile/features/people/presentation/ui/people_list_page.dart';
import 'package:near_social_mobile/features/feed/presentation/ui/posts_feed_page.dart';
import 'package:near_social_mobile/core/shared_widgets/glassmorphism_components.dart';
import 'package:near_social_mobile/core/shared_widgets/tappable_scale_widget.dart';
import 'package:near_social_mobile/core/utils/check_for_jailbreak.dart';
import 'package:near_social_mobile/features/chat/presentation/providers/chat_controller.dart';
import 'package:near_social_mobile/features/chat/presentation/ui/chat_list_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 0;
  final ValueNotifier<bool> _showBars = ValueNotifier(true);
  Timer? _hideTimer;

  late AnimationController _bgController;
  late List<BackgroundParticle> _particles;
  Size _lastSize = Size.zero;

  /// Tracks which tabs have been visited at least once (for lazy loading)
  final Set<int> _visitedTabs = {0};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
    _particles = [];

    // Eagerly initialize ChatController so signaling connects at login
    ref.read(chatControllerProvider);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _bgController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _bgController.repeat();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!kIsWeb) {
      checkForJailbreak(context);
    }
  }

  void onChildScroll() {
    if (_showBars.value) {
      _showBars.value = false;
    }
    // Reset timer on every scroll event -- bars reappear after scrolling stops
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) _showBars.value = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bgController.dispose();
    _hideTimer?.cancel();
    _showBars.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_particles.isEmpty || _lastSize != screenSize) {
      _particles = List.generate(15, (i) => BackgroundParticle(screenSize));
      _lastSize = screenSize;
    }

    return Scaffold(
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Stack(
        children: [
          // Living background
          buildLivingBackground(
            controller: _bgController,
            particles: _particles,
            screenSize: screenSize,
            isDark: isDark,
          ),

          // Page content (lazy — tabs are created on first visit)
          IndexedStack(
            index: _currentIndex,
            children: [
              PostsFeedPage(onScroll: onChildScroll),
              if (_visitedTabs.contains(1))
                PeopleListPage(onScroll: onChildScroll)
              else
                const SizedBox.shrink(),
              if (_visitedTabs.contains(2))
                ChatListPage(onScroll: onChildScroll)
              else
                const SizedBox.shrink(),
              if (_visitedTabs.contains(3))
                HomeMenuPage(onScroll: onChildScroll)
              else
                const SizedBox.shrink(),
            ],
          ),

          // Top bar
          ValueListenableBuilder<bool>(
            valueListenable: _showBars,
            builder: (context, showBars, child) => buildAnimatedPanel(
              top: true,
              showBars: showBars,
              child: child!,
            ),
            child: buildGlassBar(
              360,
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/media/icons/near_social_logo.svg',
                    height: 16,
                    width: 16,
                    colorFilter: ColorFilter.mode(
                      isDark ? Colors.white : Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _currentTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const Spacer(),
                  TappableScaleWidget(
                    scaleDown: AppAnimations.navButtonScaleDown,
                    onTap: () => showNotificationsModal(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: const Icon(
                        CupertinoIcons.bell_fill,
                        color: CupertinoColors.systemYellow,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              isDark,
            ),
          ),

          // Bottom bar
          ValueListenableBuilder<bool>(
            valueListenable: _showBars,
            builder: (context, showBars, child) => buildAnimatedPanel(
              top: false,
              showBars: showBars,
              child: child!,
            ),
            child: buildGlassBar(
              360,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navBtn(CupertinoIcons.house_fill, 0, isDark),
                  _navBtn(CupertinoIcons.person_2_fill, 1, isDark),
                  _navBtn(CupertinoIcons.chat_bubble_2_fill, 2, isDark),
                  _navBtn(CupertinoIcons.person_fill, 3, isDark),
                ],
              ),
              isDark,
            ),
          ),
        ],
      ),
      ),
    );
  }

  String get _currentTitle {
    switch (_currentIndex) {
      case 0:
        return 'Near Social';
      case 1:
        return 'Users';
      case 2:
        return 'Chat';
      case 3:
        return 'Profile';
      default:
        return 'Near Social';
    }
  }

  Widget _navBtn(IconData icon, int targetIndex, bool isDark) {
    final isActive = targetIndex == _currentIndex;
    return TappableScaleWidget(
      scaleDown: AppAnimations.navButtonScaleDown,
      onTap: () {
        setState(() {
          _visitedTabs.add(targetIndex);
          _currentIndex = targetIndex;
        });
      },
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: isActive
              ? CupertinoColors.activeBlue
              : (isDark ? Colors.white70 : CupertinoColors.secondaryLabel),
          size: 24,
        ),
      ),
    );
  }
}
