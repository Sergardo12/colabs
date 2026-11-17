import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_router.dart';
import '../../auth/bloc/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(_fade);

    // Pequeño retraso para que el logo se asiente antes del texto.
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _controller.forward();
    });

    _checkSession();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    final isValid =
        await context.read<AuthBloc>().authRepository.isSessionValid();
    if (!mounted) return;

    if (isValid) {
      Navigator.pushReplacementNamed(context, AppRouter.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          // Logo: mismo tamaño y posición que el splash nativo, sin animar.
          const Center(
            child: Image(
              image: AssetImage('assets/icons/app_icon_foreground.png'),
              width: 340,
              height: 340,
            ),
          ),
          // Texto: aparece suave, sin competir con el logo.
          Align(
            alignment: const Alignment(0, 0.45),
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: const Text(
                  'Colabs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}