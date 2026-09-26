import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

/// Estado visual del slider "Finalizar Servicio".
enum SwipeToCompleteStatus { idle, loading, success, error }

/// Botón deslizable horizontal (izquierda → derecha) para finalizar un
/// servicio en estado `in_progress` (Flujo A, vista del colaborador).
///
/// - El evento `onCompleted` se dispara UNA sola vez, solo si el usuario
///   arrastra el thumb al menos el 85% del recorrido y lo suelta ahí.
/// - Si se suelta antes del umbral, el thumb regresa con animación
///   (snap-back) y NO se dispara ningún evento.
/// - [SwipeToCompleteStatus.loading] muestra un loader en el thumb;
///   [SwipeToCompleteStatus.success] muestra un check animado;
///   [SwipeToCompleteStatus.error] reinicia el slider a la posición inicial.
class SwipeToCompleteSlider extends StatefulWidget {
  const SwipeToCompleteSlider({
    super.key,
    required this.onCompleted,
    this.status = SwipeToCompleteStatus.idle,
  });

  final VoidCallback onCompleted;
  final SwipeToCompleteStatus status;

  @override
  State<SwipeToCompleteSlider> createState() => _SwipeToCompleteSliderState();
}

class _SwipeToCompleteSliderState extends State<SwipeToCompleteSlider>
    with SingleTickerProviderStateMixin {
  static const String _label = 'Finalizar Servicio';
  static const double _inset = 6;
  static const double _thumbSize = AppSizes.buttonHeight - _inset * 2; // 44
  static const double _threshold = 0.85;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );
  Animation<double>? _slide;

  double _dragX = 0;
  double _width = 0;
  bool _fired = false;

  double get _maxExtent =>
      _width > 0 ? _width - _thumbSize - _inset * 2 : 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final slide = _slide;
      if (slide != null && mounted) {
        setState(() => _dragX = slide.value);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SwipeToCompleteSlider old) {
    super.didUpdateWidget(old);
    if (old.status != SwipeToCompleteStatus.success &&
        widget.status == SwipeToCompleteStatus.success) {
      _fired = true;
      _animateTo(_maxExtent);
    } else if (old.status == SwipeToCompleteStatus.loading &&
        widget.status == SwipeToCompleteStatus.error) {
      // El backend rechazó la finalización: vuelve a 0 y permite reintentar.
      _fired = false;
      _animateTo(0);
    }
  }

  void _animateTo(double target) {
    final start = _dragX;
    _controller.stop();
    if (start == target) return;
    _slide = Tween<double>(begin: start, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller
      ..reset()
      ..forward();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_fired || _maxExtent <= 0) return;
    // Si hay un snap-back en curso, cancelarlo para que el thumb
    // responda directamente al dedo.
    if (_controller.isAnimating) _controller.stop();
    setState(() {
      _dragX = (_dragX + details.delta.dx).clamp(0.0, _maxExtent);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_fired || _maxExtent <= 0) return;
    if (_dragX >= _maxExtent * _threshold) {
      _fired = true;
      _animateTo(_maxExtent);
      widget.onCompleted();
    } else {
      _animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;
        final maxExtent = _maxExtent;
        final progress =
            maxExtent > 0 ? (_dragX / maxExtent).clamp(0.0, 1.0) : 0.0;
        final loading = widget.status == SwipeToCompleteStatus.loading;
        final success = widget.status == SwipeToCompleteStatus.success;

        return Semantics(
          label: _label,
          button: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: Container(
              height: AppSizes.buttonHeight,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Zona de texto — centrada en el espacio libre a la
                  // derecha del thumb (en reposo el thumb tapaba "Fin").
                  Positioned(
                    left: _thumbSize + _inset * 2, // 44 + 12 = 56 px
                    right: _inset, // 6 px de respiro derecho
                    top: 0,
                    bottom: 0,
                    child: Opacity(
                      opacity: 1 - 0.85 * progress,
                      child: const Center(
                        child: Text(
                          _label,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppSizes.fontL,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Thumb arrastrable (izquierda → derecha).
                  Positioned(
                    left: _inset + _dragX,
                    top: _inset,
                    child: Container(
                      width: _thumbSize,
                      height: _thumbSize,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Center(
                        child: success
                            ? TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutBack,
                                builder: (_, scale, child) =>
                                    Transform.scale(scale: scale, child: child),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.green,
                                  size: 30,
                                ),
                              )
                            : loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Color(0xFF1E41BC),
                                    ),
                                  )
                                : Icon(
                                    Icons.chevron_right_rounded,
                                    color: colors.primary,
                                    size: 30,
                                  ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
