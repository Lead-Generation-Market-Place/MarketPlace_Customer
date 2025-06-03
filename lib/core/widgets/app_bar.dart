import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
// Placeholder for foldable_widgets import if specific responsive utils are needed later
// import '../widgets/foldable_widgets.dart'; 

class ScrollableAppBarWithFixedSearch extends StatelessWidget {
  final Widget? title;
  final List<Widget>? actions;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final String searchHintText;
  final VoidCallback? onSearchSubmitted;
  final double searchBarHeight;
  final Color? backgroundColor;
  final Color? searchBarBackgroundColor;
  final TextStyle? searchTextStyle;
  final TextStyle? searchHintStyle;
  final IconThemeData? iconTheme;
  final IconThemeData? actionsIconTheme;

  const ScrollableAppBarWithFixedSearch({
    Key? key,
    this.title,
    this.actions,
    this.searchController,
    this.onSearchChanged,
    this.searchHintText = "What do you need help with?",
    this.onSearchSubmitted,
    this.searchBarHeight = 56.0, // Standard height for a search bar area
    this.backgroundColor = AppColors.surface,
    this.searchBarBackgroundColor,
    this.searchTextStyle,
    this.searchHintStyle,
    this.iconTheme,
    this.actionsIconTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveSearchBarBackgroundColor = 
        searchBarBackgroundColor ?? AppColors.background; // Default to a light background for search
    final effectiveSearchTextStyle = 
        searchTextStyle ?? TextStyle(color: AppColors.textPrimary, fontSize: 16);
    final effectiveSearchHintStyle = 
        searchHintStyle ?? TextStyle(color: AppColors.textTertiary, fontSize: 16);

    return SliverAppBar(
      pinned: true, 
      floating: true,
      snap: true, 
      elevation: 1.0,
      backgroundColor: backgroundColor,
      iconTheme: iconTheme ?? IconThemeData(color: AppColors.textPrimary),
      actionsIconTheme: actionsIconTheme ?? IconThemeData(color: AppColors.textPrimary),
      title: title,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(searchBarHeight),
        child: Container(
          height: searchBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          color: backgroundColor, // Match AppBar background or could be distinct
          child: Container(
            decoration: BoxDecoration(
              color: effectiveSearchBarBackgroundColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              onSubmitted: (_) => onSearchSubmitted?.call(),
              style: effectiveSearchTextStyle,
              decoration: InputDecoration(
                hintText: searchHintText,
                hintStyle: effectiveSearchHintStyle,
                prefixIcon: Icon(
                  Icons.search,
                  color: effectiveSearchHintStyle.color ?? AppColors.textTertiary,
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0), // Adjust for text field height
              ),
            ),
          ),
        ),
      ),
    );
  }
}
