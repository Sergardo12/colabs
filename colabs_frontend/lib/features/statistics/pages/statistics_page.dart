import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
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
          if (state is StatisticsDataState) {
            return Column(
              children: [
                const StatisticsHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    child: _StatisticsContent(data: state.data),
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
                  child: state is StatisticsLoading
                      ? CircularProgressIndicator(
                          color: context.colors.primary,
                        )
                      : Padding(
                          padding: const EdgeInsets.all(AppSizes.paddingXL),
                          child: Text(
                            state is StatisticsError
                                ? state.message
                                : 'Cargando estadísticas...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: state is StatisticsError
                                  ? context.colors.error
                                  : context.colors.textSecondary,
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
                    child: MonthlyGoalCard(
                      data: data,
                      onSave: (amount) {
                        bloc.add(MonthlyGoalSaveRequested(amount));
                      },
                    ),
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
