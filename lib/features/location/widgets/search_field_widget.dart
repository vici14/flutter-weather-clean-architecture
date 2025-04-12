import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class SearchFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final String hintText;
  final bool alwaysShowClear;
  final EdgeInsetsGeometry padding;

  const SearchFieldWidget({
    Key? key,
    required this.controller,
    required this.onSearch,
    this.hintText = 'Search...',
    this.alwaysShowClear = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
  }) : super(key: key);

  @override
  State<SearchFieldWidget> createState() => _SearchFieldWidgetState();
}

class _SearchFieldWidgetState extends State<SearchFieldWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    widget.onSearch(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: TextField(
        controller: widget.controller,
        style: AppTextStyles.bodyStyle,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTextStyles.bodyStyle.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.accent,
          ),
          suffixIcon:
              widget.alwaysShowClear || widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.accent,
                      ),
                      onPressed: () {
                        widget.controller.clear();
                        widget.onSearch('');
                      },
                    )
                  : null,
          filled: true,
          fillColor: AppColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}
