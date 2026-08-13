import 'package:flutter_bloc/flutter_bloc.dart';
import '../../storage/theme_repository.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeRepository themeRepository;

  ThemeBloc({
    required ThemeRepository themeRepository,
    required bool initialIsDark,
  }) : themeRepository = themeRepository,
       super(ThemeState(isDark: initialIsDark)) {
    on<ToggleTheme>(_onToggleTheme);
  }

  /// Alterna el tema, lo persiste y emite el nuevo estado
  Future<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<ThemeState> emit,
  ) async {
    final isDark = !state.isDark;
    await themeRepository.saveDark(isDark);
    emit(ThemeState(isDark: isDark));
  }
}
