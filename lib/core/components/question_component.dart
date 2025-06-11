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
  final Function(dynamic)? onNext;
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

  Widget _buildMultipleChoice() {
    final selectedSet = _selectedValue is Set ? _selectedValue as Set : <dynamic>{};
    return Column(
      children: widget.question.options.map((option) {
        final isChecked = selectedSet.contains(option.value);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  if (isChecked) {
                    selectedSet.remove(option.value);
                  } else {
                    selectedSet.add(option.value);
                  }
                  _selectedValue = Set.from(selectedSet);
                });
                widget.question.onAnswer?.call(_selectedValue);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isChecked ? AppColors.primaryBlue : AppColors.neutral200,
                    width: isChecked ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            selectedSet.add(option.value);
                          } else {
                            selectedSet.remove(option.value);
                          }
                          _selectedValue = Set.from(selectedSet);
                        });
                        widget.question.onAnswer?.call(_selectedValue);
                      },
                    ),
                    if (option.icon != null) ...[
                      option.icon!,
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          color: isChecked ? AppColors.primaryBlue : AppColors.textPrimary,
                          fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
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
        return _buildMultipleChoice();
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
            onPressed: _selectedValue != null ? () => widget.onNext?.call(_selectedValue) : null,
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
      child: ListView(
   
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

class QuestionFlowScreen extends StatefulWidget {
  final List<Question> questions;
  final VoidCallback? onComplete;

  const QuestionFlowScreen({
    Key? key,
    required this.questions,
    this.onComplete,
  }) : super(key: key);

  @override
  State<QuestionFlowScreen> createState() => _QuestionFlowScreenState();
}

class _QuestionFlowScreenState extends State<QuestionFlowScreen> {
  int _current = 0;
  final Map<String, dynamic> _answers = {};

  void _next(dynamic answer) {
    if (answer != null) {
      setState(() {
        _answers[widget.questions[_current].id] = answer;
      });
    }
    
    if (_current < widget.questions.length - 1) {
      setState(() => _current++);
    } else {
      widget.onComplete?.call();
      Navigator.of(context).pop(_answers);
    }
  }

  void _back() {
    if (_current > 0) {
      setState(() => _current--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_current];
    return Scaffold(
      appBar: AppBar(
        leading: _current > 0
            ? IconButton(icon: Icon(Icons.arrow_back), onPressed: _back)
            : null,
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
      body: QuestionComponent(
        question: question,
        initialValue: _answers[question.id],
        onNext: _next,
        onBack: _back,
        showActions: true,
      ),
    );
  }
}
