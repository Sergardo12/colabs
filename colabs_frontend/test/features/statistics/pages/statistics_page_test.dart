import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:colabs_frontend/core/constants/app_strings.dart';
import 'package:colabs_frontend/features/statistics/data/mock_statistics_repository.dart';
import 'package:colabs_frontend/features/statistics/data/statistics_repository.dart';
import 'package:colabs_frontend/features/statistics/pages/statistics_page.dart';

void main() {
  testWidgets('renderiza el módulo sin overflow en pantalla pequeña',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: RepositoryProvider<StatisticsRepository>(
          create: (_) => MockStatisticsRepository(
            delay: Duration.zero,
          ),
          child: const StatisticsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.servicesOffered), findsOneWidget);
    expect(find.text(AppStrings.periodDays), findsWidgets);
    expect(find.text(AppStrings.servicesLabel), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('colaborador nuevo sin servicios, calificaciones ni meta',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RepositoryProvider<StatisticsRepository>(
          create: (_) => MockStatisticsRepository(
            empty: true,
            delay: Duration.zero,
          ),
          child: const StatisticsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.noServicesYet), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.text(AppStrings.monthlyGoalQuestion), findsOneWidget);
    expect(find.text(AppStrings.loadStatisticsError), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
