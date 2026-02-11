import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:near_social_mobile/core/shared_widgets/spinner_loading_indicator.dart';

class LoadingPageWithNavigation extends StatefulWidget {
  const LoadingPageWithNavigation({
    super.key,
    required this.function,
    required this.route,
  });

  final Future<dynamic> Function() function;
  final String route;

  @override
  State<LoadingPageWithNavigation> createState() =>
      _LoadingPageWithNavigationState();
}

class _LoadingPageWithNavigationState extends State<LoadingPageWithNavigation> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.function().then(
        (_) {
          if (mounted) {
            context.go(widget.route);
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SpinnerLoadingIndicator(),
      ),
    );
  }
}
