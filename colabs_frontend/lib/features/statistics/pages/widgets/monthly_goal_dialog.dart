import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../bloc/statistics_bloc.dart';
import '../../bloc/statistics_event.dart';
import '../../bloc/statistics_state.dart';

Future<void> showMonthlyGoalDialog(
  BuildContext context, {
  required StatisticsBloc bloc,
  int? amount,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => MonthlyGoalDialog(bloc: bloc, amount: amount),
  );
}

class MonthlyGoalDialog extends StatefulWidget {
  final StatisticsBloc bloc;
  final int? amount;

  const MonthlyGoalDialog({super.key, required this.bloc, this.amount});

  @override
  State<MonthlyGoalDialog> createState() => _MonthlyGoalDialogState();
}

class _MonthlyGoalDialogState extends State<MonthlyGoalDialog> {
  final _controller = TextEditingController();
  late int _initialRevision;
  String? _error;
  bool _saveRequested = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.amount?.toString() ?? '';
    _initialRevision = widget.bloc.state.goalSaveRevision;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isValidAmount(int? amount) =>
      amount != null && amount >= 1 && amount <= 999;

  bool get _canSave => _isValidAmount(int.tryParse(_controller.text));

  void _save() {
    final parsedAmount = int.tryParse(_controller.text);
    if (!_isValidAmount(parsedAmount)) return;
    final amount = parsedAmount!;
    setState(() => _error = null);
    _saveRequested = true;
    _initialRevision = widget.bloc.state.goalSaveRevision;
    widget.bloc.add(MonthlyGoalSaveRequested(amount));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StatisticsBloc, StatisticsState>(
      bloc: widget.bloc,
      listener: (context, state) {
        if (_saveRequested &&
            state.goalSaveRevision > _initialRevision &&
            !state.goalSaving &&
            state.goalError == null) {
          Navigator.of(context).pop();
          return;
        }
        if (state.goalError != null && state.goalError != _error) {
          setState(() => _error = state.goalError);
        }
      },
      builder: (context, state) {
        final saving = state.goalSaving;
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                enabled: !saving,
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
              if (_error != null) ...[
                const SizedBox(height: AppSizes.paddingXS),
                Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: AppSizes.fontS,
                  ),
                ),
              ],
            ],
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
                onPressed: _canSave && !saving ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  minimumSize: const Size.fromHeight(
                    AppSizes.inputMedianHeight,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                ),
                child: saving
                    ? SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.colors.white,
                          ),
                        ),
                      )
                    : const Text(AppStrings.save),
              ),
            ),
          ],
        );
      },
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
