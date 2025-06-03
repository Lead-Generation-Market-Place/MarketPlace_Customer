import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

enum QuestionType {
  singleChoice,
  multipleChoice,
  text,
  number,
  boolean
}

class QuestionOption {
  final String id;
  final String label;
  final dynamic value;
  final Widget? icon;

  const QuestionOption({
    required this.id,
    required this.label,
    required this.value,
    this.icon,
  });
}

class Question {
  final String id;
  final String question;
  final QuestionType type;
  final List<QuestionOption> options;
  final bool isRequired;
  final String? helperText;
  final Function(dynamic)? onAnswer;

  const Question({
    required this.id,
    required this.question,
    required this.type,
    this.options = const [],
    this.isRequired = true,
    this.helperText,
    this.onAnswer,
  });
}

class QuestionComponent extends StatefulWidget {
  final Question question;
  final dynamic initialValue;
  final EdgeInsetsGeometry? padding;
  final bool showDivider;
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final bool showActions;

  const QuestionComponent({
    Key? key,
    required this.question,
    this.initialValue,
    this.padding,
    this.showDivider = true,
    this.onNext,
    this.onBack,
    this.showActions = true,
  }) : super(key: key);

  @override
  State<QuestionComponent> createState() => _QuestionComponentState();
}

class _QuestionComponentState extends State<QuestionComponent> {
  dynamic _selectedValue;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    if (widget.question.type == QuestionType.text && widget.initialValue != null) {
      _textController.text = widget.initialValue.toString();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSelection(dynamic value) {
    setState(() {
      _selectedValue = value;
    });
    widget.question.onAnswer?.call(value);
  }

  Widget _buildSingleChoice() {
    return Column(
      children: widget.question.options.map((option) {
        final isSelected = _selectedValue == option.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleSelection(option.value),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? AppColors.primaryBlue : AppColors.neutral200,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primaryBlue : AppColors.neutral400,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    if (option.icon != null) ...[
                      option.icon!,
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuestionContent() {
    switch (widget.question.type) {
      case QuestionType.singleChoice:
        return _buildSingleChoice();
      case QuestionType.multipleChoice:
        // Implement multiple choice UI
        return Container(); // Placeholder
      case QuestionType.text:
        // Implement text input UI
        return Container(); // Placeholder
      case QuestionType.number:
        // Implement number input UI
        return Container(); // Placeholder
      case QuestionType.boolean:
        // Implement boolean UI
        return Container(); // Placeholder
    }
  }

  Widget _buildActions() {
    if (!widget.showActions) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          if (widget.onBack != null)
            TextButton(
              onPressed: widget.onBack,
              child: Text('Back'.tr),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: _selectedValue != null ? widget.onNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Next'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.question.question,
            style: Get.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.question.helperText != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.question.helperText!,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 24),
          _buildQuestionContent(),
          _buildActions(),
          if (widget.showDivider)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Divider(),
            ),
        ],
      ),
    );
  }
}
