import 'package:flutter/material.dart';
import 'package:near_social_mobile/config/theme.dart';

class DefaultAppBar extends StatelessWidget {
  final VoidCallback onSearchPressed;

  const DefaultAppBar({super.key, required this.onSearchPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: NEARColors.blue,
      title: Text(
        'User Chats',
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(color: NEARColors.white),
      ),
      actions: [
        IconButton(
          onPressed: onSearchPressed,
          icon: Icon(Icons.search),
        ),
      ],
    );
  }
}

class SearchAppBar extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onCancel;

  const SearchAppBar({
    super.key,
    required this.searchController,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: NEARColors.blue,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: onCancel,
      ),
      title: TextField(
        controller: searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search users...',
          border: InputBorder.none,
          hintStyle: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: NEARColors.white),
        ),
        style: TextStyle(color: NEARColors.white),
      ),
    );
  }
}
