import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// A web-only image widget that renders via an HTML <img> element,
/// completely bypassing CORS restrictions that affect XHR-based loaders.
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

  String get _objectFit {
    switch (fit) {
      case BoxFit.contain:
        return 'contain';
      case BoxFit.fill:
        return 'fill';
      case BoxFit.fitWidth:
      case BoxFit.fitHeight:
      case BoxFit.cover:
        return 'cover';
      case BoxFit.none:
        return 'none';
      case BoxFit.scaleDown:
        return 'scale-down';
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewType = 'near-img-${imageUrl.hashCode}';

    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final img = web.document.createElement('img') as web.HTMLImageElement;
        img.src = imageUrl;
        img.style.width = '100%';
        img.style.height = '100%';
        img.style.objectFit = _objectFit;
        img.style.display = 'block';
        return img;
      },
    );

    return HtmlElementView(viewType: viewType);
  }
}
