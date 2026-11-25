import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../bloc/statistics_bloc.dart';
import '../bloc/statistics_event.dart';
import '../bloc/statistics_state.dart';
import '../data/statistics_repository.dart';
import '../models/statistics_data.dart';
import 'widgets/monthly_goal_card.dart';
import 'widgets/rating_summary_card.dart';
import 'widgets/services_offered_section.dart';
import 'widgets/services_rate_card.dart';
import 'widgets/statistics_header.dart';
import 'widgets/total_services_card.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StatisticsBloc(
        repository: context.read<StatisticsRepository>(),
      )..add(const StatisticsLoadRequested()),
      child: const StatisticsView(),
    );
  }
}

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: BlocConsumer<StatisticsBloc, StatisticsState>(
        listenWhen: (previous, current) =>
            current.snackMessage != null &&
            current.snackMessage != previous.snackMessage,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                backgroundColor: context.colors.error,
                content: Text(state.snackMessage!),
              ),
            );
        },
        builder: (context, state) {
          final data = switch (state) {
            StatisticsDataState state => state.data,
            StatisticsLoading state => state.data,
            _ => null,
          };

          if (data != null) {
            return Column(
              children: [
                const StatisticsHeader(),
                if (state is StatisticsLoading)
                  LinearProgressIndicator(
                    minHeight: 2,
                    color: context.colors.primary,
                    backgroundColor: context.colors.surface,
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    child: _StatisticsContent(data: data),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              const StatisticsHeader(),
              Expanded(
                child: Center(
                  child: state is StatisticsError
                      ? _ErrorContent(message: state.message)
                      : state is StatisticsLoading
                          ? CircularProgressIndicator(
                              color: context.colors.primary,
                            )
                          : Padding(
                              padding: const EdgeInsets.all(AppSizes.paddingXL),
                              child: Text(
                                AppStrings.loadingStatistics,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: context.colors.textSecondary,
                                  fontSize: AppSizes.fontL,
                                ),
                              ),
                            ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String message;

  const _ErrorContent({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.error,
              fontSize: AppSizes.fontL,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          ElevatedButton(
            onPressed: () {
              context.read<StatisticsBloc>().add(
                    const StatisticsLoadRequested(),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
                vertical: AppSizes.paddingS,
              ),
              minimumSize: const Size(0, AppSizes.inputMedianHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
            child: Text(
              AppStrings.retry,
              style: TextStyle(
                color: context.colors.white,
                fontSize: AppSizes.fontM,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  final StatisticsData data;

  const _StatisticsContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StatisticsBloc>();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ServicesOfferedSection(
              data: data,
              onPeriodChanged: (period) {
                bloc.add(StatisticsPeriodChanged(period));
              },
            ),
            const SizedBox(height: AppSizes.paddingM),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: MonthlyGoalCard(data: data, bloc: bloc),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(child: ServicesRateCard(data: data)),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: RatingSummaryCard(data: data)),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(child: TotalServicesCard(data: data)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
