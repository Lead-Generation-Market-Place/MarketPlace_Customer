import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

enum CustomInputType {
  text,
  email,
  password,
  phone,
  number,
  multiline,
  search
}

class CustomInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final CustomInputType type;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final BoxConstraints? constraints;
  final String? Function(String?)? onSubmitted;
  final bool showCursor;
  final double? cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final bool autocorrect;
  final bool enableSuggestions;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final Brightness? keyboardAppearance;
  final InputDecoration? decoration;

  const CustomInput({
    Key? key,
    this.label,
    this.hint,
    this.initialValue,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.type = CustomInputType.text,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.controller,
    this.focusNode,
    this.contentPadding,
    this.constraints,
    this.onSubmitted,
    this.showCursor = true,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.scrollController,
    this.scrollPhysics,
    this.keyboardAppearance,
    this.decoration,
  }) : super(key: key);

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _obscureText = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.type == CustomInputType.password;
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus != _isFocused) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  TextInputType _getKeyboardType() {
    if (widget.keyboardType != null) return widget.keyboardType!;
    
    switch (widget.type) {
      case CustomInputType.email:
        return TextInputType.emailAddress;
      case CustomInputType.phone:
        return TextInputType.phone;
      case CustomInputType.number:
        return TextInputType.number;
      case CustomInputType.multiline:
        return TextInputType.multiline;
      case CustomInputType.search:
        return TextInputType.text;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    final formatters = <TextInputFormatter>[];
    
    if (widget.inputFormatters != null) {
      formatters.addAll(widget.inputFormatters!);
    }

    switch (widget.type) {
      case CustomInputType.phone:
        formatters.add(FilteringTextInputFormatter.digitsOnly);
        break;
      case CustomInputType.number:
        formatters.add(FilteringTextInputFormatter.digitsOnly);
        break;
      default:
        break;
    }

    return formatters;
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon != null) return widget.suffixIcon;
    
    if (widget.type == CustomInputType.password) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: _isFocused ? AppColors.primaryBlue : AppColors.neutral500,
          size: 24, // Explicit size for visibility
        ),
        onPressed: _togglePasswordVisibility,
        splashRadius: 20, // Smaller splash for better UX
        tooltip: _obscureText ? 'Show password' : 'Hide password', // Accessibility
      );
    }

    if (widget.type == CustomInputType.search) {
      return IconButton(
        icon: const Icon(Icons.search),
        color: AppColors.neutral500,
        onPressed: () {
          // Trigger search action
        },
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      obscureText: _obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      maxLines: widget.type == CustomInputType.multiline ? widget.maxLines : 1,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      keyboardType: _getKeyboardType(),
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      validator: widget.validator,
      inputFormatters: _getInputFormatters(),
      style: TextStyle(
        color: widget.enabled 
          ? (isDark ? Colors.white : AppColors.textPrimary)
          : AppColors.neutral500,
      ),
      cursorColor: widget.cursorColor ?? AppColors.primaryBlue,
      cursorWidth: widget.cursorWidth!,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      showCursor: widget.showCursor,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      scrollController: widget.scrollController,
      scrollPhysics: widget.scrollPhysics,
      keyboardAppearance: widget.keyboardAppearance,
      decoration: widget.decoration ?? InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefix: widget.prefix,
        suffix: widget.suffix,
        prefixIcon: widget.prefixIcon,
        suffixIcon: _buildSuffixIcon(),
        contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        constraints: widget.constraints,
        filled: true,
        fillColor: widget.enabled
            ? (isDark ? AppColors.neutral800 : AppColors.neutral50)
            : (isDark ? AppColors.neutral900 : AppColors.neutral100),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? AppColors.neutral700 : AppColors.neutral200,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? AppColors.neutral700 : AppColors.neutral200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.primaryBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? AppColors.neutral800 : AppColors.neutral100,
          ),
        ),
      ),
    );
  }
}