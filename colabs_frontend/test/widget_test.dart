import 'package:colabs_frontend/core/bloc/theme/theme_bloc.dart';
import 'package:colabs_frontend/core/bloc/theme/theme_event.dart';
import 'package:colabs_frontend/core/bloc/theme/theme_state.dart';
import 'package:colabs_frontend/core/network/api_client.dart';
import 'package:colabs_frontend/core/storage/theme_repository.dart';
import 'package:colabs_frontend/core/theme/app_theme.dart';
import 'package:colabs_frontend/features/profile/bloc/profile_bloc.dart';
import 'package:colabs_frontend/features/profile/data/profile_repository.dart';
import 'package:colabs_frontend/features/profile/data/profile_service.dart';
import 'package:colabs_frontend/features/profile/models/profile_model.dart';
import 'package:colabs_frontend/features/profile/pages/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repositorio fake — evita llamadas de red al cargar el perfil del drawer.
class _FakeProfileRepository extends ProfileRepository {
  _FakeProfileRepository()
      : super(
          profileService: ProfileService(ApiClient.create()),
          secureStorage:  const FlutterSecureStorage(),
        );

  @override
  Future<({UserProfileModel user, ColabProfileModel? colab})>
      getMyProfile() async {
    return (
      user: const UserProfileModel(
        id:               'u1',
        email:            'test@colabs.app',
        name:             'Juan',
        lastName:         'Pérez',
        phoneNumber:      '3001234567',
        registrationDate: '2024-01-01',
      ),
      colab: null,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThemeBloc themeBloc;
  late ProfileBloc profileBloc;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    themeBloc = ThemeBloc(
      themeRepository: const ThemeRepository(),
      initialIsDark:   prefs.getBool('theme_dark') ?? false,
    );
    profileBloc = ProfileBloc(profileRepository: _FakeProfileRepository());
  });

  tearDown(() {
    themeBloc.close();
    profileBloc.close();
  });

  /// Reproduce el cableado de [ColabsApp] (app.dart): BlocBuilder de ThemeBloc
  /// que define theme/darkTheme/themeMode y un Scaffold con el AppDrawer.
  Widget buildApp() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>.value(value: themeBloc),
        BlocProvider<ProfileBloc>.value(value: profileBloc),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            theme:     AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state.isDark ? ThemeMode.dark : ThemeMode.light,
            home: Scaffold(
              key:     scaffoldKey,
              appBar:  AppBar(),
              drawer:  const AppDrawer(),
              body:    const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }

  testWidgets(
      'el toggle de tema del drawer activa el modo oscuro y lo persiste',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    themeBloc = ThemeBloc(
      themeRepository: const ThemeRepository(),
      initialIsDark:   prefs.getBool('theme_dark') ?? false,
    );
    profileBloc = ProfileBloc(profileRepository: _FakeProfileRepository());

    await tester.pumpWidget(buildApp());
    await tester.pump();

    MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app().themeMode, ThemeMode.light);

    scaffoldKey.currentState!.openDrawer();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.text('Cambiar tema'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.pump();

    expect(app().themeMode, ThemeMode.dark);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

    final savedPrefs = await SharedPreferences.getInstance();
    expect(savedPrefs.getBool('theme_dark'), isTrue);
  });

  test('ThemeBloc alterna el estado y guarda la preferencia', () async {
    expect(themeBloc.state.isDark, isFalse);

    themeBloc.add(const ToggleTheme());
    await themeBloc.stream.firstWhere((s) => s.isDark);

    expect(themeBloc.state.isDark, isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('theme_dark'), isTrue);
  });
}
