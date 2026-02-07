import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ModernDesignTestPage extends StatelessWidget {
  const ModernDesignTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(primaryColor: CupertinoColors.activeBlue),
      home: MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- ГЛАВНЫЙ ЭКРАН С НАВИГАЦИЕЙ ---
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _currentIndex,
      children: [
        LivingEcosystemScreen(
          onNavigate: (index) => setState(() => _currentIndex = index),
          currentIndex: _currentIndex,
        ),
        LivingWidgetsScreen(
          onNavigate: (index) => setState(() => _currentIndex = index),
          currentIndex: _currentIndex,
        ),
        LivingUsersScreen(
          onNavigate: (index) => setState(() => _currentIndex = index),
          currentIndex: _currentIndex,
        ),
        FinalProfileScreen(
          onNavigate: (index) => setState(() => _currentIndex = index),
          currentIndex: _currentIndex,
        ),
      ],
    );
  }
}

// --- СИСТЕМА ЧАСТИЦ (Единый ДНК дизайна) ---
class BackgroundParticle {
  late Offset position;
  late Offset velocity;
  late double size;
  late double rotation;
  late double rotationSpeed;
  late double opacityPhase;
  late IconData? icon;
  late String? svgPath;

  /// [icons] может содержать IconData или String (путь к SVG-ассету).
  BackgroundParticle(Size screenSize, {List<Object>? icons}) {
    final random = math.Random();
    position = Offset(random.nextDouble() * screenSize.width,
        random.nextDouble() * screenSize.height);
    velocity =
        Offset(random.nextDouble() * 0.4 - 0.2, random.nextDouble() * 0.4 - 0.2);
    size = 30 + random.nextDouble() * 90;
    rotation = random.nextDouble() * math.pi * 2;
    rotationSpeed = (random.nextDouble() - 0.5) * 0.01;
    opacityPhase = random.nextDouble() * math.pi * 2;
    final List<Object> defaultIcons = [
      'assets/media/icons/near_social_logo.svg',
      CupertinoIcons.bell_fill,
      'assets/media/icons/near_social_logo.svg',
    ];
    final chosen = (icons ?? defaultIcons)[random.nextInt((icons ?? defaultIcons).length)];
    if (chosen is String) {
      svgPath = chosen;
      icon = null;
    } else {
      icon = chosen as IconData;
      svgPath = null;
    }
  }

  void update(Size screenSize) {
    position += velocity;
    rotation += rotationSpeed;
    opacityPhase += 0.005;

    if (position.dx < -size) position = Offset(screenSize.width + size, position.dy);
    if (position.dx > screenSize.width + size) position = Offset(-size, position.dy);
    if (position.dy < -size) position = Offset(position.dx, screenSize.height + size);
    if (position.dy > screenSize.height + size) position = Offset(position.dx, -size);
  }
}

// ============================================================
// ЭКРАН ЛЕНТЫ (FEED) - Index 0
// ============================================================
class LivingEcosystemScreen extends StatefulWidget {
  final Function(int) onNavigate;
  final int currentIndex;

  const LivingEcosystemScreen({
    super.key,
    required this.onNavigate,
    required this.currentIndex,
  });

  @override
  State<LivingEcosystemScreen> createState() => _LivingEcosystemScreenState();
}

class _LivingEcosystemScreenState extends State<LivingEcosystemScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showBars = true;
  Timer? _hideTimer;

  late List<BackgroundParticle> _particles;
  late AnimationController _bgController;
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
    _particles = [];
  }

  void _handleScroll() {
    if (_showBars) setState(() => _showBars = false);
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showBars = true);
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _scrollController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    if (_particles.isEmpty || _lastSize != screenSize) {
      _particles = List.generate(25, (i) => BackgroundParticle(screenSize));
      _lastSize = screenSize;
    }

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          _buildLivingBackground(_bgController, _particles, screenSize, isDark),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => AppleVibrantCard(isDark: isDark),
                      childCount: 10,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ),
            ),
          ),
          buildAnimatedPanel(
              top: true,
              showBars: _showBars,
              child: buildTopBar('Near Social', isDark)),
          buildAnimatedPanel(
              top: false,
              showBars: _showBars,
              child: buildBottomBar(widget.currentIndex, widget.onNavigate, isDark)),
        ],
      ),
    );
  }
}

// ============================================================
// ЭКРАН ВИДЖЕТОВ (WIDGETS) - Index 1
// ============================================================
class LivingWidgetsScreen extends StatefulWidget {
  final Function(int) onNavigate;
  final int currentIndex;

  const LivingWidgetsScreen({
    super.key,
    required this.onNavigate,
    required this.currentIndex,
  });

  @override
  State<LivingWidgetsScreen> createState() => _LivingWidgetsScreenState();
}

class _LivingWidgetsScreenState extends State<LivingWidgetsScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showBars = true;
  Timer? _hideTimer;
  late List<BackgroundParticle> _particles;
  late AnimationController _bgController;
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
    _particles = [];
  }

  void _handleScroll() {
    if (_showBars) setState(() => _showBars = false);
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showBars = true);
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _scrollController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    if (_particles.isEmpty || _lastSize != screenSize) {
      _particles = List.generate(
        20,
        (i) => BackgroundParticle(screenSize, icons: [
          'assets/media/icons/near_social_logo.svg',
          CupertinoIcons.bell_fill,
          'assets/media/icons/near_social_logo.svg',
        ]),
      );
      _lastSize = screenSize;
    }

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          _buildLivingBackground(
            _bgController, _particles, screenSize, isDark,
            gradientBegin: Alignment.topLeft,
            gradientEnd: Alignment.bottomRight,
            darkColors: [const Color(0xFF000000), const Color(0xFF0C0C24)],
            lightColors: [const Color(0xFFE5E5EA), const Color(0xFFF2F2F7)],
            particleColor: isDark ? Colors.white : Colors.black38,
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                  SliverToBoxAdapter(child: _buildGlassSearch(isDark)),
                  SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildWidgetCard(index, isDark),
                        childCount: 15,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ),
            ),
          ),
          buildAnimatedPanel(
              top: true,
              showBars: _showBars,
              child: buildTopBar('Widgets', isDark)),
          buildAnimatedPanel(
              top: false,
              showBars: _showBars,
              child: buildBottomBar(widget.currentIndex, widget.onNavigate, isDark)),
        ],
      ),
    );
  }

  Widget _buildGlassSearch(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: isDark
                      ? Colors.white10
                      : Colors.white.withValues(alpha: 0.5)),
            ),
            child: CupertinoTextField(
              placeholder: 'Search widgets...',
              placeholderStyle:
                  TextStyle(color: isDark ? Colors.white38 : Colors.black38),
              prefix: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(CupertinoIcons.search,
                    size: 20, color: CupertinoColors.systemGrey),
              ),
              decoration: null,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetCard(int index, bool isDark) {
    final titles = [
      "NEAR Treasury Factory",
      "NEAR Treasury",
      "Aura Component",
      "Social Dashboard"
    ];
    final title = titles[index % titles.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: isDark
                      ? Colors.white10
                      : Colors.white.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withValues(alpha: 0.8),
                        Colors.teal.withValues(alpha: 0.8)
                      ],
                    ),
                  ),
                  child: const Icon(CupertinoIcons.cube_fill,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const Text('By near_factory.near',
                          style: TextStyle(
                              color: CupertinoColors.secondaryLabel,
                              fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(CupertinoIcons.chevron_right,
                    size: 14, color: CupertinoColors.secondaryLabel),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ЭКРАН ПОЛЬЗОВАТЕЛЕЙ (USERS) - Index 2
// ============================================================
class LivingUsersScreen extends StatefulWidget {
  final Function(int) onNavigate;
  final int currentIndex;

  const LivingUsersScreen({
    super.key,
    required this.onNavigate,
    required this.currentIndex,
  });

  @override
  State<LivingUsersScreen> createState() => _LivingUsersScreenState();
}

class _LivingUsersScreenState extends State<LivingUsersScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showBars = true;
  Timer? _hideTimer;
  late List<BackgroundParticle> _particles;
  late AnimationController _bgController;
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
    _particles = [];
  }

  void _handleScroll() {
    if (_showBars) setState(() => _showBars = false);
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showBars = true);
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _scrollController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    if (_particles.isEmpty || _lastSize != screenSize) {
      _particles = List.generate(
        22,
        (i) => BackgroundParticle(screenSize, icons: [
          'assets/media/icons/near_social_logo.svg',
          CupertinoIcons.bell_fill,
          'assets/media/icons/near_social_logo.svg',
        ]),
      );
      _lastSize = screenSize;
    }

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          _buildLivingBackground(
            _bgController, _particles, screenSize, isDark,
            darkColors: [const Color(0xFF000000), const Color(0xFF0F0F2D)],
            lightColors: [const Color(0xFFD1D1D6), const Color(0xFFF2F2F7)],
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                  SliverToBoxAdapter(child: _buildGlassSearchBar(isDark)),
                  SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildUserCard(index, isDark),
                        childCount: 20,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ),
            ),
          ),
          buildAnimatedPanel(
              top: true,
              showBars: _showBars,
              child: buildTopBar('Users', isDark)),
          buildAnimatedPanel(
              top: false,
              showBars: _showBars,
              child: buildBottomBar(widget.currentIndex, widget.onNavigate, isDark)),
        ],
      ),
    );
  }

  Widget _buildGlassSearchBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: isDark
                      ? Colors.white12
                      : Colors.black.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)
              ],
            ),
            child: CupertinoTextField(
              placeholder: 'Search for people...',
              placeholderStyle:
                  TextStyle(color: isDark ? Colors.white38 : Colors.black45),
              prefix: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(CupertinoIcons.search,
                    size: 22, color: CupertinoColors.systemGrey),
              ),
              decoration: null,
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(int index, bool isDark) {
    final names = [
      "Eugene The Dream",
      "Vadim",
      "Anna",
      "Pedro",
      "Toolipse"
    ];
    final handles = [
      "@mob.near",
      "@zavodil.near",
      "@guseva.near",
      "@dompedro.near",
      "@toolipse.near"
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                  color: isDark
                      ? Colors.white10
                      : Colors.white.withValues(alpha: 0.4)),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8))
                    ],
            ),
            child: Row(
              children: [
                // Squircle Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: CupertinoColors.systemGrey5,
                  ),
                  child: const Icon(CupertinoIcons.person_fill,
                      color: Colors.white38),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(names[index % names.length],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: -0.3)),
                      Text(handles[index % handles.length],
                          style: const TextStyle(
                              color: CupertinoColors.secondaryLabel,
                              fontSize: 13)),
                    ],
                  ),
                ),
                // Follow button
                CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  minSize: 0,
                  color:
                      isDark ? CupertinoColors.white : CupertinoColors.black,
                  borderRadius: BorderRadius.circular(15),
                  onPressed: () {},
                  child: Text('Follow',
                      style: TextStyle(
                          color: isDark ? Colors.black : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ЭКРАН ПРОФИЛЯ (PROFILE) - Index 3
// ============================================================
class FinalProfileScreen extends StatefulWidget {
  final Function(int) onNavigate;
  final int currentIndex;

  const FinalProfileScreen({
    super.key,
    required this.onNavigate,
    required this.currentIndex,
  });

  @override
  State<FinalProfileScreen> createState() => _FinalProfileScreenState();
}

class _FinalProfileScreenState extends State<FinalProfileScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showBars = true;
  Timer? _hideTimer;
  late List<BackgroundParticle> _particles;
  late AnimationController _bgController;
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
    _particles = [];
  }

  void _handleScroll() {
    if (_showBars) setState(() => _showBars = false);
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showBars = true);
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _scrollController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    if (_particles.isEmpty || _lastSize != screenSize) {
      _particles = List.generate(20, (i) => BackgroundParticle(screenSize));
      _lastSize = screenSize;
    }

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          _buildLivingBackground(_bgController, _particles, screenSize, isDark),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                  SliverToBoxAdapter(child: _buildCompactHeader(context, isDark)),
                  SliverToBoxAdapter(child: _buildSocialStats(context, isDark)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildMenuTile(index, context, isDark),
                        childCount: 3,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ),
            ),
          ),
          buildAnimatedPanel(
              top: true,
              showBars: _showBars,
              child: buildTopBar('Profile', isDark)),
          buildAnimatedPanel(
              top: false,
              showBars: _showBars,
              child: buildBottomBar(widget.currentIndex, widget.onNavigate, isDark)),
        ],
      ),
    );
  }

  Widget _buildCompactHeader(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                  color: isDark
                      ? Colors.white10
                      : Colors.white.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 38,
                  backgroundColor: CupertinoColors.systemGrey5,
                  child: Icon(CupertinoIcons.person_fill,
                      size: 38, color: Colors.white38),
                ),
                const SizedBox(height: 12),
                const Text('No Name',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text('0x682ff...8d155ec0',
                    style: TextStyle(
                        color:
                            CupertinoColors.secondaryLabel.resolveFrom(context),
                        fontSize: 13)),
                const SizedBox(height: 16),
                CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                  color: isDark ? CupertinoColors.white : CupertinoColors.black,
                  borderRadius: BorderRadius.circular(20),
                  onPressed: () {},
                  child: Text('Edit Profile',
                      style: TextStyle(
                          color: isDark ? Colors.black : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialStats(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _statBox("128", "Posts", isDark),
          const SizedBox(width: 8),
          _statBox("432", "Following", isDark),
          const SizedBox(width: 8),
          _statBox("1.2k", "Followers", isDark),
        ],
      ),
    );
  }

  Widget _statBox(String val, String lab, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: isDark
                  ? Colors.white12
                  : Colors.white.withValues(alpha: 0.6)),
        ),
        child: Column(
          children: [
            Text(val,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(lab,
                style: const TextStyle(
                    fontSize: 11, color: CupertinoColors.secondaryLabel)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(int index, BuildContext context, bool isDark) {
    final menuItems = [
      ["Settings", CupertinoIcons.settings_solid],
      ["Modern Design Test", CupertinoIcons.paintbrush_fill],
      ["Help & Support", CupertinoIcons.question_circle_fill],
    ];
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: isDark
                      ? Colors.white10
                      : Colors.white.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(menuItems[index][1] as IconData,
                    size: 20, color: isDark ? Colors.white70 : Colors.black87),
                const SizedBox(width: 16),
                Text(menuItems[index][0] as String,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                const Spacer(),
                const Icon(CupertinoIcons.chevron_right,
                    size: 14, color: CupertinoColors.secondaryLabel),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ОБЩИЕ КОМПОНЕНТЫ И ФУНКЦИИ
// ============================================================

// --- ЖИВОЙ ФОН (общий для всех экранов) ---
Widget _buildLivingBackground(
  AnimationController controller,
  List<BackgroundParticle> particles,
  Size screenSize,
  bool isDark, {
  Alignment gradientBegin = Alignment.topCenter,
  Alignment gradientEnd = Alignment.bottomCenter,
  List<Color>? darkColors,
  List<Color>? lightColors,
  Color? particleColor,
}) {
  return AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      for (var p in particles) {
        p.update(screenSize);
      }
      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: gradientBegin,
                end: gradientEnd,
                colors: isDark
                    ? (darkColors ??
                        [const Color(0xFF000000), const Color(0xFF0A0A1F)])
                    : (lightColors ??
                        [const Color(0xFFE5E5EA), const Color(0xFFD1D1D6)]),
              ),
            ),
          ),
          ...particles.map((p) {
                final pColor = particleColor ?? (isDark ? Colors.white : Colors.black45);
                return Positioned(
                  left: p.position.dx,
                  top: p.position.dy,
                  child: Opacity(
                    opacity:
                        (math.sin(p.opacityPhase) * 0.04 + 0.05).clamp(0.01, 0.1),
                    child: p.svgPath != null
                        ? SvgPicture.asset(
                            p.svgPath!,
                            width: p.size,
                            height: p.size,
                            colorFilter: ColorFilter.mode(pColor, BlendMode.srcIn),
                          )
                        : Icon(p.icon, size: p.size, color: pColor),
                  ),
                );
              }),
        ],
      );
    },
  );
}

// --- АНИМИРОВАННЫЕ ПАНЕЛИ ---
Widget buildAnimatedPanel({
  required bool top,
  required bool showBars,
  required Widget child,
}) {
  return AnimatedPositioned(
    duration: const Duration(milliseconds: 800),
    curve: Curves.easeInOutCubic,
    top: top ? (showBars ? 50 : -120) : null,
    bottom: top ? null : (showBars ? 40 : -120),
    left: 0,
    right: 0,
    child: Center(child: child),
  );
}

// --- TOP BAR ---
Widget buildTopBar(String title, bool isDark) {
  return _vibrantGlassBar(
    360,
    Row(
      children: [
        _circleIcon(CupertinoIcons.infinite, isDark),
        const Spacer(),
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                letterSpacing: -0.5)),
        const Spacer(),
        const Icon(CupertinoIcons.bell_fill,
            color: CupertinoColors.systemYellow, size: 24),
      ],
    ),
    isDark,
  );
}

// --- BOTTOM BAR ---
Widget buildBottomBar(int currentIndex, Function(int) onNavigate, bool isDark) {
  return _vibrantGlassBar(
    340,
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _navBtn(CupertinoIcons.house_fill, 0, currentIndex, onNavigate, isDark),
        _navBtn(CupertinoIcons.square_grid_2x2_fill, 1, currentIndex, onNavigate, isDark),
        _circleIcon(CupertinoIcons.add, isDark, size: 44),
        _navBtn(CupertinoIcons.person_2_fill, 2, currentIndex, onNavigate, isDark),
        _navBtn(CupertinoIcons.person_fill, 3, currentIndex, onNavigate, isDark),
      ],
    ),
    isDark,
  );
}

Widget _navBtn(IconData icon, int targetIndex, int currentIndex,
    Function(int) onNavigate, bool isDark) {
  final isActive = targetIndex == currentIndex;
  return GestureDetector(
    onTap: targetIndex >= 0 ? () => onNavigate(targetIndex) : null,
    child: Icon(icon,
        color: isActive
            ? CupertinoColors.activeBlue
            : (isDark ? Colors.white70 : CupertinoColors.secondaryLabel),
        size: 26),
  );
}

Widget _vibrantGlassBar(double width, Widget child, bool isDark) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(40),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
          blurRadius: 35,
        )
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
        child: Container(
          width: width,
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.14),
                      Colors.white.withValues(alpha: 0.06)
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.95),
                      Colors.white.withValues(alpha: 0.85)
                    ],
            ),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: isDark
                  ? Colors.white24
                  : Colors.black.withValues(alpha: 0.12),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    ),
  );
}

Widget _circleIcon(IconData icon, bool isDark, {double size = 32}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: isDark ? Colors.white : Colors.black,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)
      ],
    ),
    child: Icon(icon,
        color: isDark ? Colors.black : Colors.white, size: size * 0.55),
  );
}

// --- КАРТОЧКА ПОСТА (для Feed) ---
class AppleVibrantCard extends StatelessWidget {
  final bool isDark;
  const AppleVibrantCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 30,
                    offset: const Offset(0, 15))
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                  color: isDark
                      ? Colors.white10
                      : Colors.white.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                        radius: 20,
                        backgroundColor: CupertinoColors.systemGrey5),
                    const SizedBox(width: 14),
                    const Text('Top Secret',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    Icon(CupertinoIcons.ellipsis,
                        color: CupertinoColors.secondaryLabel
                            .resolveFrom(context)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                    'Это абсолютно живая система. Фон дышит, иконки плавают асинхронно, а интерфейс скрывается, когда он не нужен.',
                    style: TextStyle(fontSize: 15, height: 1.5)),
                const SizedBox(height: 20),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
