import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/exceptions/exceptions.dart';
import 'package:near_social_mobile/shared_widgets/image_full_screen_page.dart';
import 'package:near_social_mobile/shared_widgets/near_network_image.dart';
import 'package:near_social_mobile/utils/near_widget_opener_interface.dart';
import 'package:url_launcher/url_launcher.dart';

class RawTextToContentFormatter extends StatelessWidget {
  const RawTextToContentFormatter({
    super.key,
    required this.rawText,
    this.selectable = true,
    this.tappable = true,
    this.heroAnimForImages = true,
    this.loadImages = true,
  });

  final String rawText;
  final bool selectable;
  final bool tappable;
  final bool heroAnimForImages;
  final bool loadImages;

  bool _isNearWidget(String url) => url.contains("/widget/");

  (String, String?) _urlToWidgetSettings(String url) {
    String extractPath(String url) {
      // Parse the URL
      final uri = Uri.parse(url);

      // Split the path into segments
      List<String> segments = uri.pathSegments;

      // Reconstruct the path by joining the relevant segments
      String path =
          segments.takeWhile((segment) => segment != 'widget').join('/') +
              '/widget';

      // Append the rest of the path after 'widget'
      int widgetIndex = segments.indexOf('widget');
      if (widgetIndex != -1 && widgetIndex + 1 < segments.length) {
        path += '/' + segments.sublist(widgetIndex + 1).join('/');
      }

      return path;
    }

    String? getWidgetPropsFormUrl(String url) {
      final Uri uri = Uri.parse(url);
      if (uri.queryParameters.isEmpty) {
        return null;
      }
      final Map<String, dynamic> params = uri.queryParameters;
      final jsonString = jsonEncode(params);
      return jsonString;
    }

    final widgetPath = extractPath(url);
    final props = getWidgetPropsFormUrl(url);

    return (widgetPath, props);
  }

  void _launchURL(String urlText) async {
    final Uri url = Uri.parse(urlText);
    if (_isNearWidget(urlText)) {
      final (widgetPath, props) = _urlToWidgetSettings(urlText);
      openNearWidget(widgetPath: widgetPath, initWidgetProps: props);
    } else if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw AppExceptions(
        messageForUser: 'Could not launch $url',
        messageForDev: 'Could not launch $url',
        statusCode: 1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = rawText.replaceAll("\\n", "\n");
    return MarkdownBody(
      data: text,
      imageBuilder: (uri, title, alt) {
        if (!loadImages) {
          return Text.rich(TextSpan(
            text: uri.toString(),
          ));
        }
        return GestureDetector(
          onTap: tappable
              ? () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    Modular.routerDelegate.navigatorKey.currentContext!,
                    MaterialPageRoute(
                      builder: (context) => ImageFullScreen(
                        imageUrl: uri.toString(),
                      ),
                    ),
                  );
                }
              : null,
          child: heroAnimForImages
              ? Hero(
                  tag: uri.toString(),
                  child: NearNetworkImage(
                    imageUrl: uri.toString(),
                    errorPlaceholder: const Icon(Icons.broken_image),
                  ),
                )
              : NearNetworkImage(
                  imageUrl: uri.toString(),
                  errorPlaceholder: const Icon(Icons.broken_image),
                ),
        );
      },
      onTapLink: tappable
          ? (text, href, title) {
              showAdaptiveDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 20.sp,
                        ),
                        text: "Do you want to open ?\n",
                        children: [
                          TextSpan(
                            text: href,
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Modular.to.pop(false);
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Modular.to.pop(true);
                        },
                        child: const Text("Open"),
                      ),
                    ],
                  );
                },
              ).then((toOpen) {
                if (toOpen != null && toOpen) {
                  _launchURL(href!);
                }
              });
            }
          : null,
      selectable: selectable,
      onSelectionChanged: (text, selection, cause) {},
    );
  }
}
