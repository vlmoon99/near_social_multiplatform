import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/config/theme.dart';

/// System Management Page
///
/// This page was previously used to manage Supabase server connections.
/// In decentralized mode, this functionality is disabled.
///
/// Future implementations may include:
/// - NEAR RPC node selection
/// - IPFS gateway configuration
/// - Indexer endpoint management
class SystemsManagmentPage extends StatelessWidget {
  const SystemsManagmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Systems Management'),
        backgroundColor: NEARColors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F9FF),
              Color(0xFFF8F9FF),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off,
                  size: 80.sp,
                  color: NEARColors.grey,
                ),
                SizedBox(height: 24.h),
                Text(
                  'Decentralized Mode',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: NEARColors.black,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Server management is disabled in decentralized mode.\n\n'
                  'The app now operates directly with the NEAR blockchain '
                  'without relying on centralized servers.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: NEARColors.grey,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: NEARColors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: NEARColors.blue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: NEARColors.blue,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Connected to NEAR Mainnet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: NEARColors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
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
