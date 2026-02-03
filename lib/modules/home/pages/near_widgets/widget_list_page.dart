import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:near_social_mobile/modules/home/apis/models/near_widget_info.dart';
import 'package:near_social_mobile/modules/home/pages/near_widgets/widgets/near_widget_tile.dart';
import 'package:near_social_mobile/modules/home/pages/shared_design/glassmorphism_components.dart';
import 'package:near_social_mobile/modules/home/vms/near_widgets/near_widgets_controller.dart';
import 'package:near_social_mobile/shared_widgets/spinner_loading_indicator.dart';

class NearWidgetListPage extends StatefulWidget {
  const NearWidgetListPage({super.key, this.onScroll});

  final VoidCallback? onScroll;

  @override
  State<NearWidgetListPage> createState() => _NearWidgetListPageState();
}

class _NearWidgetListPageState extends State<NearWidgetListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {});
    });
    _scrollController.addListener(() {
      widget.onScroll?.call();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final NearWidgetsController nearWidgetsController =
          Modular.get<NearWidgetsController>();
      if (nearWidgetsController.state.status == NearWidgetStatus.initial) {
        nearWidgetsController.getNearWidgets();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nearWidgetsController = Modular.get<NearWidgetsController>();

    return StreamBuilder<NearWidgets>(
      stream: nearWidgetsController.stream,
      builder: (context, _) {
        if (nearWidgetsController.state.status != NearWidgetStatus.loaded) {
          return const Center(child: SpinnerLoadingIndicator());
        }

        final List<NearWidgetInfo> nearWidgets = searchController.text != ""
            ? nearWidgetsController.state.widgetList
                .where(
                  (element) =>
                      element.name.contains(
                        RegExp(searchController.text, caseSensitive: false),
                      ) ||
                      element.urlName.contains(
                        RegExp(searchController.text, caseSensitive: false),
                      ),
                )
                .toList()
            : nearWidgetsController.state.widgetList;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 90)),
                SliverToBoxAdapter(
                  child: GlassSearchBar(
                    controller: searchController,
                    isDark: isDark,
                    placeholder: 'Search widgets...',
                  ),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final nearWidget = nearWidgets[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: NearWidgetTile(nearWidget: nearWidget),
                        );
                      },
                      childCount: nearWidgets.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 90)),
              ],
            ),
          ),
        );
      },
    );
  }
}
