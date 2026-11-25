import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:colabs_frontend/core/constants/app_sizes.dart';
import 'package:colabs_frontend/core/constants/app_strings.dart';
import 'package:colabs_frontend/features/statistics/data/mock_statistics_repository.dart';
import 'package:colabs_frontend/features/statistics/data/statistics_repository.dart';
import 'package:colabs_frontend/features/statistics/models/bar_datum.dart';
import 'package:colabs_frontend/features/statistics/models/monthly_goal.dart';
import 'package:colabs_frontend/features/statistics/models/services_offered_response.dart';
import 'package:colabs_frontend/features/statistics/models/services_rate.dart';
import 'package:colabs_frontend/features/statistics/models/statistics_data.dart';
import 'package:colabs_frontend/features/statistics/models/statistics_period.dart';
import 'package:colabs_frontend/features/statistics/pages/statistics_page.dart';
import 'package:colabs_frontend/features/statistics/pages/widgets/services_bar_chart.dart';

void main() {
  testWidgets('renderiza el módulo sin overflow en pantalla pequeña', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: RepositoryProvider<StatisticsRepository>(
          create: (_) => MockStatisticsRepository(delay: Duration.zero),
          child: const StatisticsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.servicesOffered), findsOneWidget);
    expect(find.text(AppStrings.periodDays), findsWidgets);
    expect(find.text(AppStrings.servicesLabel), findsWidgets);
    expect(tester.takeException(), isNull);

    for (final period in [
      AppStrings.periodDays,
      AppStrings.periodMonths,
      AppStrings.periodYears,
    ]) {
      await _tapPeriod(tester, period);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('colaborador nuevo sin servicios, calificaciones ni meta', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RepositoryProvider<StatisticsRepository>(
          create: (_) =>
              MockStatisticsRepository(empty: true, delay: Duration.zero),
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

  testWidgets('abrir sin meta no guarda y mantiene el diálogo abierto', (
    tester,
  ) async {
    final repository = _RecordingStatisticsRepository();
    await _pumpPage(tester, repository);
    await _tapLabel(tester, AppStrings.markGoal);

    expect(find.text(AppStrings.enterGoal), findsOneWidget);
    expect(repository.savedAmounts, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sin meta el campo empieza vacío y Guardar deshabilitado', (
    tester,
  ) async {
    final repository = _RecordingStatisticsRepository();
    await _pumpPage(tester, repository);
    await _tapLabel(tester, AppStrings.markGoal);

    expect(_fieldText(tester), isEmpty);
    expect(tester.widget<ElevatedButton>(_saveButton()).onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('monto fuera de rango no despacha el guardado', (tester) async {
    final repository = _RecordingStatisticsRepository();
    await _pumpPage(tester, repository);
    await _tapLabel(tester, AppStrings.markGoal);
    await tester.enterText(find.byType(TextField), '0');
    await tester.pump();

    expect(_fieldText(tester), '0');
    expect(tester.widget<ElevatedButton>(_saveButton()).onPressed, isNull);
    await tester.tap(_saveButton());
    await tester.pumpAndSettle();

    expect(repository.savedAmounts, isEmpty);
    expect(find.text(AppStrings.enterGoal), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Guardar con monto válido guarda una sola vez y cierra', (
    tester,
  ) async {
    final repository = _RecordingStatisticsRepository();
    await _pumpPage(tester, repository);
    await _tapLabel(tester, AppStrings.markGoal);
    await tester.enterText(find.byType(TextField), '12');
    await tester.pump();

    expect(_fieldText(tester), '12');
    expect(tester.widget<ElevatedButton>(_saveButton()).onPressed, isNotNull);
    await tester.tap(_saveButton());
    await tester.pumpAndSettle();

    expect(repository.savedAmounts, <int>[12]);
    expect(find.text(AppStrings.enterGoal), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cerrar con X no guarda y quita el diálogo', (tester) async {
    final repository = _RecordingStatisticsRepository();
    await _pumpPage(tester, repository);
    await _tapLabel(tester, AppStrings.markGoal);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(repository.savedAmounts, isEmpty);
    expect(find.text(AppStrings.enterGoal), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editar precarga el monto y no guarda hasta confirmar', (
    tester,
  ) async {
    final now = DateTime.now();
    final repository = _RecordingStatisticsRepository(
      initialGoal: MonthlyGoal(amount: 25, month: now.month, year: now.year),
    );
    await _pumpPage(tester, repository);
    await _tapLabel(tester, AppStrings.editGoal);

    expect(_fieldText(tester), '25');
    expect(repository.savedAmounts, isEmpty);

    await tester.enterText(find.byType(TextField), '30');
    await tester.pump();
    await tester.tap(_saveButton());
    await tester.pumpAndSettle();

    expect(repository.savedAmounts, <int>[30]);
    expect(find.text(AppStrings.enterGoal), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reabrir tras guardado exitoso no auto-guarda', (tester) async {
    final repository = _RecordingStatisticsRepository();
    await _pumpPage(tester, repository);
    await _tapLabel(tester, AppStrings.markGoal);
    await tester.enterText(find.byType(TextField), '10');
    await tester.pump();
    await tester.tap(_saveButton());
    await tester.pumpAndSettle();

    expect(repository.savedAmounts, <int>[10]);

    await _tapLabel(tester, AppStrings.editGoal);

    expect(find.text(AppStrings.enterGoal), findsOneWidget);
    expect(_fieldText(tester), '10');
    expect(repository.savedAmounts, <int>[10]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('eje Y con máximos de tres dígitos no se corta ni toca el eje', (
    tester,
  ) async {
    for (final maxValue in <int>[135, 200]) {
      final data = StatisticsData.empty(StatisticsPeriod.years).copyWith(
        bars: <BarDatum>[
          BarDatum(key: DateTime.now().year, value: maxValue.toDouble()),
        ],
      );
      await _pumpChart(tester, data);

      final chartRect = tester.getRect(find.byType(ServicesBarChart));
      final axisLeft =
          chartRect.left + AppSizes.chartLeftInsetForMax(data.yAxisMax);
      final labelFinder = find.descendant(
        of: find.byType(ServicesBarChart),
        matching: find.text(data.yAxisMax.toString()),
      );

      expect(labelFinder, findsOneWidget);
      final labelRect = tester.getRect(labelFinder);
      expect(labelRect.left, greaterThanOrEqualTo(chartRect.left));
      expect(
        labelRect.right,
        lessThanOrEqualTo(axisLeft - AppSizes.chartAxisStroke / 2),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('etiquetas de días y eje Y quedan fuera del área de barras', (
    tester,
  ) async {
    final data = StatisticsData.empty(StatisticsPeriod.days);
    await _pumpChart(tester, data);

    final chartRect = tester.getRect(find.byType(ServicesBarChart));
    final axisLeft =
        chartRect.left + AppSizes.chartLeftInsetForMax(data.yAxisMax);
    final axisBottom =
        chartRect.top + AppSizes.chartHeight - AppSizes.chartBottomInset;
    final dayFinder = find.descendant(
      of: find.byType(ServicesBarChart),
      matching: find.text('L'),
    );
    final yFinder = find.descendant(
      of: find.byType(ServicesBarChart),
      matching: find.text(data.yAxisMax.toString()),
    );

    expect(dayFinder, findsOneWidget);
    expect(yFinder, findsOneWidget);
    expect(tester.getRect(dayFinder).top, greaterThan(axisBottom));
    expect(
      tester.getRect(yFinder).right,
      lessThanOrEqualTo(axisLeft - AppSizes.chartAxisStroke / 2),
    );
    expect(tester.takeException(), isNull);
  });

  test('etiquetas largas de meses caben en el espacio inferior', () {
    final painter = TextPainter(
      text: TextSpan(
        text: 'Septiembre',
        style: const TextStyle(fontSize: AppSizes.fontS),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final angle = AppSizes.chartMonthLabelAngle.abs();
    final rotatedHeight =
        painter.width * math.sin(angle) + painter.height * math.cos(angle);

    expect(
      rotatedHeight + AppSizes.chartTitleSpace,
      lessThanOrEqualTo(AppSizes.chartBottomReserved),
    );
  });

  test('doce barras de Mes no se solapan a 320 px', () {
    const screenWidth = 320.0;
    final chartWidth = screenWidth - AppSizes.paddingM * 4;
    final data = StatisticsData.empty(StatisticsPeriod.months);
    final barCount = data.bars.length;
    final rodWidth = AppSizes.chartRodWidth(
      barCount: barCount,
      chartWidth: chartWidth,
      yAxisMax: data.yAxisMax,
    );
    final plotLeft =
        AppSizes.chartLeftInsetForMax(data.yAxisMax) -
        AppSizes.chartLeftReserved +
        AppSizes.chartAxisStroke / 2 +
        AppSizes.chartLeftReserved;
    final plotRight =
        chartWidth - AppSizes.chartRightInset - AppSizes.chartAxisStroke / 2;

    expect(barCount, 12);
    expect(rodWidth * barCount, lessThanOrEqualTo(plotRight - plotLeft));
    expect(rodWidth, lessThan(180 / barCount));
  });
}

class _RecordingStatisticsRepository implements StatisticsRepository {
  _RecordingStatisticsRepository({this.initialGoal})
    : _delegate = MockStatisticsRepository();

  final StatisticsRepository _delegate;
  MonthlyGoal? initialGoal;
  final List<int> savedAmounts = <int>[];

  @override
  Future<ServicesOfferedResponse> getServicesOffered(StatisticsPeriod period) {
    return _delegate.getServicesOffered(period);
  }

  @override
  Future<int> getServicesTotal(StatisticsPeriod period) {
    return _delegate.getServicesTotal(period);
  }

  @override
  Future<ServicesRate> getServicesRate() {
    return _delegate.getServicesRate();
  }

  @override
  Future<double?> getAverageRating() {
    return _delegate.getAverageRating();
  }

  @override
  Future<MonthlyGoal?> getMonthlyGoal() async => initialGoal;

  @override
  Future<MonthlyGoal> saveMonthlyGoal(int amount) async {
    savedAmounts.add(amount);
    final now = DateTime.now();
    initialGoal = MonthlyGoal(amount: amount, month: now.month, year: now.year);
    return initialGoal!;
  }
}

Future<void> _pumpPage(
  WidgetTester tester,
  _RecordingStatisticsRepository repository,
) async {
  await tester.binding.setSurfaceSize(const Size(400, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      home: RepositoryProvider<StatisticsRepository>(
        create: (_) => repository,
        child: const StatisticsPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapPeriod(WidgetTester tester, String label) async {
  final finder = find.widgetWithText(InkWell, label);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _pumpChart(WidgetTester tester, StatisticsData data) async {
  final chartWidth = 320.0 - AppSizes.paddingM * 4;
  await tester.binding.setSurfaceSize(const Size(320, 640));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: chartWidth,
            child: ServicesBarChart(data: data),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapLabel(WidgetTester tester, String label) async {
  final finder = find.text(label);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Finder _saveButton() => find.widgetWithText(ElevatedButton, AppStrings.save);

String _fieldText(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!.text;
