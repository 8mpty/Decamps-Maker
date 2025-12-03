import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuas_decamps_maker/models/time_data.dart';

class TimeSection extends StatefulWidget {
  final String title;
  final TextEditingController hourController;
  final TextEditingController minuteController;
  final TextEditingController secondController;
  final ValueChanged<TimeData?>? onTimeChanged;

  const TimeSection({
    super.key,
    required this.title,
    required this.hourController,
    required this.minuteController,
    required this.secondController,
    this.onTimeChanged,
  });

  @override
  State<TimeSection> createState() => _TimeSectionState();
}

class _TimeSectionState extends State<TimeSection> {
  final FocusNode _hourFocusNode = FocusNode();
  final FocusNode _minuteFocusNode = FocusNode();
  final FocusNode _secondFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _setupAutoFocus();
    _setupListeners();
  }

  void _setupAutoFocus() {
    _hourFocusNode.addListener(() {
      if (!_hourFocusNode.hasFocus && widget.hourController.text.length == 2) {
        FocusScope.of(context).requestFocus(_minuteFocusNode);
      }
    });

    _minuteFocusNode.addListener(() {
      if (!_minuteFocusNode.hasFocus && widget.minuteController.text.length == 2) {
        FocusScope.of(context).requestFocus(_secondFocusNode);
      }
    });
  }

  void _setupListeners() {
    widget.hourController.addListener(_notifyTimeChanged);
    widget.minuteController.addListener(_notifyTimeChanged);
    widget.secondController.addListener(_notifyTimeChanged);
  }

  void _notifyTimeChanged() {
    final hourStr = widget.hourController.text;
    final minuteStr = widget.minuteController.text;
    final secondStr = widget.secondController.text;

    if (hourStr.isEmpty && minuteStr.isEmpty && secondStr.isEmpty) {
      widget.onTimeChanged?.call(null);
      return;
    }

    if (hourStr.isEmpty || minuteStr.isEmpty || secondStr.isEmpty) {
      widget.onTimeChanged?.call(null);
      return;
    }

    final hour = int.tryParse(hourStr);
    final minute = int.tryParse(minuteStr);
    final second = int.tryParse(secondStr);

    if (hour == null || minute == null || second == null) {
      widget.onTimeChanged?.call(null);
      return;
    }

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59 || second < 0 || second > 59) {
      widget.onTimeChanged?.call(null);
      return;
    }

    widget.onTimeChanged?.call(TimeData(hour, minute, second));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildTimeInput(
              context,
              "HH",
              widget.hourController,
              _hourFocusNode,
              _minuteFocusNode,
              isHour: true,
            ),
            const SizedBox(width: 8),
            Text(
              ":",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(width: 8),
            _buildTimeInput(
              context,
              "MM",
              widget.minuteController,
              _minuteFocusNode,
              _secondFocusNode,
            ),
            const SizedBox(width: 8),
            Text(
              ":",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(width: 8),
            _buildTimeInput(
              context,
              "SS",
              widget.secondController,
              _secondFocusNode,
              null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeInput(
    BuildContext context,
    String hint,
    TextEditingController controller,
    FocusNode currentFocus,
    FocusNode? nextFocus, {
    bool isHour = false,
  }) {
    return Expanded(
      child: TextField(
        controller: controller,
        focusNode: currentFocus,
        keyboardType: TextInputType.number,
        maxLength: 2,
        style: TextStyle(
          fontSize: 18,
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          counterText: "",
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        textAlign: TextAlign.center,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
        onChanged: (value) {
          if (value.length == 2 && nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          }

          if (value.isNotEmpty) {
            int? number = int.tryParse(value);
            if (number != null) {
              if (isHour && number > 23) {
                controller.text = "23";
                controller.selection = TextSelection.collapsed(offset: 2);
                _showError(context, "Hours must be between 00-23");
              } else if (!isHour && number > 59) {
                controller.text = "59";
                controller.selection = TextSelection.collapsed(offset: 2);
                _showError(context, "$hint must be between 00-59");
              }
            }
          }
        },
        onTap: () {
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        },
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _hourFocusNode.dispose();
    _minuteFocusNode.dispose();
    _secondFocusNode.dispose();
    widget.hourController.removeListener(_notifyTimeChanged);
    widget.minuteController.removeListener(_notifyTimeChanged);
    widget.secondController.removeListener(_notifyTimeChanged);
    super.dispose();
  }
}