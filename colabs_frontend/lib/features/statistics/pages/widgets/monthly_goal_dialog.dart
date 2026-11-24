import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';

Future<String?> showMonthlyGoalDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const MonthlyGoalDialog(),
  );
}

class MonthlyGoalDialog extends StatefulWidget {
  const MonthlyGoalDialog({super.key});

  @override
  State<MonthlyGoalDialog> createState() => _MonthlyGoalDialogState();
}

class _MonthlyGoalDialogState extends State<MonthlyGoalDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSave {
    final text = _controller.text;
    return text.isNotEmpty && int.tryParse(text) != null && int.parse(text) > 0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      titlePadding: const EdgeInsets.only(
        top: AppSizes.paddingM,
        left: AppSizes.paddingL,
        right: AppSizes.paddingS,
        bottom: AppSizes.paddingS,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              AppStrings.enterGoal,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: AppSizes.fontXL,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: context.colors.textSecondary),
          ),
        ],
      ),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
          _NoLeadingZeroFormatter(),
        ],
        onChanged: (_) => setState(() {}),
        style: TextStyle(color: context.colors.textPrimary),
        decoration: InputDecoration(
          labelText: AppStrings.goalFieldLabel,
          labelStyle: TextStyle(color: context.colors.textSecondary),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: context.colors.textSecondary),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: context.colors.primary),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.paddingL,
            0,
            AppSizes.paddingL,
            AppSizes.paddingL,
          ),
          child: ElevatedButton(
            onPressed: _canSave
                ? () => Navigator.pop<String>(context, _controller.text)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              minimumSize: const Size.fromHeight(AppSizes.inputMedianHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
            child: const Text(AppStrings.save),
          ),
        ),
      ],
    );
  }
}

class _NoLeadingZeroFormatter extends TextInputFormatter {
  const _NoLeadingZeroFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
