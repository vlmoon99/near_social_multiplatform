import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/config/constants.dart';
import 'package:near_social_mobile/modules/home/apis/models/near_widget_info.dart';
import 'package:near_social_mobile/shared_widgets/near_network_image.dart';
import 'package:near_social_mobile/utils/near_widget_opener_interface.dart';

class NearWidgetTile extends StatelessWidget {
  const NearWidgetTile({super.key, required this.nearWidget});

  final NearWidgetInfo nearWidget;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0).r,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0).r,
        onTap: () {
          HapticFeedback.lightImpact();
          openNearWidget(
            widgetPath: nearWidget.widgetPath,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(15).r,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40.h,
                child: Row(
                  children: [
                    Container(
                      width: 40.h,
                      height: 40.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10).r,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: NearNetworkImage(
                        imageUrl: nearWidget.imageUrl,
                        errorPlaceholder:
                            Image.asset(NearAssets.widgetPlaceholder),
                        placeholder: Image.asset(NearAssets.widgetPlaceholder),
                      ),
                    ),
                    SizedBox(width: 10.h),
                    Expanded(
                      child: Text(
                        nearWidget.name != ""
                            ? nearWidget.name
                            : nearWidget.urlName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
              if (nearWidget.description != "") ...[
                SizedBox(height: 10.h),
                Text(nearWidget.description),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
