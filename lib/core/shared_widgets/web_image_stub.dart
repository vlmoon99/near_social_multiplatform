import 'package:flutter/widgets.dart';

/// Stub for non-web platforms. Should never be instantiated.
class WebImage extends StatelessWidget {
  const WebImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.errorPlaceholder,
  });

  final String imageUrl;
  final BoxFit fit;
  final Widget? errorPlaceholder;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
