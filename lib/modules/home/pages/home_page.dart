import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:near_social_mobile/modules/home/pages/home_menu/home_menu_page.dart';
import 'package:near_social_mobile/modules/home/pages/near_widgets/widget_list_page.dart';
import 'package:near_social_mobile/modules/home/pages/notifications/notifications_page.dart';
import 'package:near_social_mobile/modules/home/pages/people/people_list_page.dart';
import 'package:near_social_mobile/modules/home/pages/posts_page/posts_feed_page.dart';
import 'package:near_social_mobile/modules/home/pages/posts_page/widgets/create_post_dialog_body.dart';
import 'package:near_social_mobile/modules/home/pages/shared_design/glassmorphism_components.dart';
import 'package:near_social_mobile/utils/check_for_jailbreak.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final ValueNotifier<bool> _showBars = ValueNotifier(true);
  bool _showNotifications = false;
  Timer? _hideTimer;

  late AnimationController _bgController;
  late List<BackgroundParticle> _particles;
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
    _particles = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!kIsWeb) {
      checkForJailbreak();
    }
  }

  void onChildScroll() {
    if (_showBars.value) {
      _showBars.value = false;
    }
    // Reset timer on every scroll event — bars reappear after scrolling stops
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) _showBars.value = true;
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _hideTimer?.cancel();
    _showBars.dispose();
    super.dispose();
  }

  void _onCreatePost() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) {
        return const Dialog.fullscreen(
          child: CreatePostDialog(),
        );
      },
    );
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

          // Page content
          IndexedStack(
            index: _currentIndex,
            children: [
              PostsFeedPage(onScroll: onChildScroll),
              NearWidgetListPage(onScroll: onChildScroll),
              PeopleListPage(onScroll: onChildScroll),
              HomeMenuPage(onScroll: onChildScroll),
            ],
          ),

          // Notifications overlay (shown when _showNotifications is true)
          if (_showNotifications) NotificationsPage(onScroll: onChildScroll),

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
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _showNotifications = !_showNotifications);
                    },
                    child: Icon(CupertinoIcons.bell_fill,
                        color: _showNotifications
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemYellow,
                        size: 24),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _navBtn(CupertinoIcons.house_fill, 0, isDark),
                  _navBtn(CupertinoIcons.square_grid_2x2_fill, 1, isDark),
                  GestureDetector(
                    onTap: _onCreatePost,
                    child:
                        buildCircleIcon(CupertinoIcons.add, isDark, size: 44),
                  ),
                  _navBtn(CupertinoIcons.person_2_fill, 2, isDark),
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
    if (_showNotifications) return 'Alerts';
    switch (_currentIndex) {
      case 0:
        return 'Near Social';
      case 1:
        return 'Widgets';
      case 2:
        return 'Users';
      case 3:
        return 'Profile';
      default:
        return 'Near Social';
    }
  }

  Widget _navBtn(IconData icon, int targetIndex, bool isDark) {
    final isActive = targetIndex == _currentIndex && !_showNotifications;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _currentIndex = targetIndex;
          _showNotifications = false;
        });
      },
      child: Icon(icon,
          color: isActive
              ? CupertinoColors.activeBlue
              : (isDark ? Colors.white70 : CupertinoColors.secondaryLabel),
          size: 24),
    );
  }
}
