import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_social_mobile/config/theme.dart';
import 'package:near_social_mobile/modules/home/vms/chats/models/chat_model.dart';

class ChatTypeSelectionModal extends StatefulWidget {
  const ChatTypeSelectionModal({super.key});

  @override
  _ChatTypeSelectionModalState createState() => _ChatTypeSelectionModalState();
}

class _ChatTypeSelectionModalState extends State<ChatTypeSelectionModal> {
  int _currentStage = 0;
  ChatType? _selectedChatType;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: NEARColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getCurrentTitle(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: NEARColors.black,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            _buildCurrentStageContent(),
            SizedBox(height: 20.h),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  String _getCurrentTitle() {
    switch (_currentStage) {
      case 0:
        return 'Choose Chat Type';
      default:
        return 'Create Chat';
    }
  }

  Widget _buildCurrentStageContent() {
    switch (_currentStage) {
      case 0:
        return _buildChatTypeSelection();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildChatTypeSelection() {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: ChatType.values.map((type) {
        return _buildSelectableCard(
          title: type.label,
          icon: type.icon,
          isSelected: _selectedChatType == type,
          onTap: () {
            setState(() {
              _selectedChatType = type;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSelectableCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.w,
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color:
              isSelected ? NEARColors.blue.withOpacity(0.2) : NEARColors.white,
          border: Border.all(
            color: isSelected ? NEARColors.blue : NEARColors.grey,
            width: 2.w,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40.sp,
              color: isSelected ? NEARColors.blue : NEARColors.grey,
            ),
            SizedBox(height: 10.h),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? NEARColors.blue : NEARColors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: _currentStage == 0
          ? MainAxisAlignment.center
          : MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(100.w, 50.h),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          ),
          onPressed: _canProceed() ? _handleNextOrCreate : null,
          child: Text(_currentStage == 1 ? 'Create Chat' : 'Next'),
        ),
      ],
    );
  }

  bool _canProceed() {
    switch (_currentStage) {
      case 0:
        return _selectedChatType != null;
      default:
        return false;
    }
  }

  void _handleNextOrCreate() {
    if (_currentStage == 0) {
      Navigator.of(context).pop({
        'chatType': _selectedChatType,
      });
    }
  }
}
