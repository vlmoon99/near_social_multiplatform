import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:near_social_mobile/core/shared_widgets/custom_button.dart';
import 'package:near_social_mobile/core/shared_widgets/image_full_screen_page.dart';
import 'package:near_social_mobile/core/shared_widgets/near_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class RawTextToContentFormatter extends StatelessWidget {
  const RawTextToContentFormatter({
    super.key,
    required this.rawText,
    this.heroAnimForImages = true,
    this.imageHeight,
    this.responsive = true,
    this.textColor,
  });

  final String rawText;
  final bool responsive;
  final bool heroAnimForImages;
  final double? imageHeight;
  final Color? textColor;

  void _launchURL(String urlText) async {
    final Uri url = Uri.parse(urlText);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = rawText.replaceAll("\\n", "\n");
    final defaultTextColor = textColor ?? Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    final baseStyle = TextStyle(fontSize: 15, color: defaultTextColor, height: 1.4, decoration: TextDecoration.none);
    final markdownStyleSheet = MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: baseStyle,
      pPadding: EdgeInsets.zero,
      h1: baseStyle.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
      h2: baseStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
      h3: baseStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
      h4: baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
      h5: baseStyle.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
      h6: baseStyle.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
      a: baseStyle.copyWith(color: Colors.blue, decoration: TextDecoration.none),
      em: baseStyle.copyWith(fontStyle: FontStyle.italic),
      strong: baseStyle.copyWith(fontWeight: FontWeight.bold),
      del: baseStyle.copyWith(decoration: TextDecoration.lineThrough),
      blockquote: baseStyle.copyWith(color: defaultTextColor.withValues(alpha: 0.7)),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: defaultTextColor.withValues(alpha: 0.3), width: 3),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
      code: TextStyle(
        fontSize: 13,
        color: defaultTextColor,
        backgroundColor: defaultTextColor.withValues(alpha: 0.08),
        decoration: TextDecoration.none,
      ),
      codeblockDecoration: BoxDecoration(
        color: defaultTextColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      listBullet: baseStyle,
      blockSpacing: 8,
    );
    return Stack(
      children: [
        MarkdownBody(
          data: text,
          styleSheet: markdownStyleSheet,
          imageBuilder: (uri, title, alt) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageFullScreen(
                      imageUrl: uri.toString(),
                    ),
                  ),
                );
              },
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxHeight: imageHeight ?? double.infinity),
                  child: heroAnimForImages
                      ? Hero(
                          tag: uri.toString(),
                          child: NearNetworkImage(
                            imageUrl: uri.toString(),
                            boxFit: BoxFit.contain,
                          ),
                        )
                      : NearNetworkImage(
                          imageUrl: uri.toString(),
                          boxFit: BoxFit.contain,
                        ),
                ),
              ),
            );
          },
          onTapLink: (text, href, title) {
            showAdaptiveDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                      text: "Do you want to open ?\n",
                      children: [
                        TextSpan(
                          text: href,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  actionsAlignment: MainAxisAlignment.spaceEvenly,
                  actions: [
                    CustomButton(
                      primary: true,
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text(
                        "Open",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    CustomButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ).then((toOpen) {
              if (toOpen != null && toOpen) {
                _launchURL(href!);
              }
            });
          },
          selectable: responsive,
        ),
        if (!responsive)
          Positioned.fill(
            child: Container(
              color: Colors.transparent,
            ),
          ),
      ],
    );
  }
}
