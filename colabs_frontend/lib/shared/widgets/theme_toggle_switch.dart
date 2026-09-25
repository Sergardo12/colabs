import 'package:flutter/material.dart';

/// Switch animado de cambio de tema (día/noche) basado en el diseño
/// "Theme Switch" de Uiverse (JustCode14).
///
/// - [isDarkMode] `true` = noche (luna + estrellas, fondo #2A2A2A).
/// - [isDarkMode] `false` = día (sol + nube, fondo #00A6FF).
/// - [onChanged] se invoca con el nuevo valor al tocar el switch.
class ThemeToggleSwitch extends StatelessWidget {
  const ThemeToggleSwitch({
    super.key,
    required this.isDarkMode,
    required this.onChanged,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  // Medidas derivadas del CSS original (font-size: 17px -> 1em = 17.0).
  static const double _em = 17.0;
  static const Duration _duration = Duration(milliseconds: 400);
  static const Cubic _knobCurve = Cubic(0.81, -0.04, 0.38, 1.5);
  static const Color _dayTrack = Color(0xFF00A6FF);
  static const Color _nightTrack = Color(0xFF2A2A2A);
  static const Color _sunColor = Color(0xFFFFCF48);

  static const double _width = 4 * _em; // 68
  static const double _height = 2.2 * _em; // 37.4
  static const double _knobSize = 1.2 * _em; // 20.4
  static const double _margin = 0.5 * _em; // 8.5
  static const double _travel = 1.8 * _em; // 30.6

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: isDarkMode,
      label: isDarkMode ? 'Cambiar a tema claro' : 'Cambiar a tema oscuro',
      child: GestureDetector(
        onTap: () => onChanged(!isDarkMode),
        child: Container(
          width: _width,
          height: _height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(color: Color(0x1A000000), blurRadius: 10),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: AnimatedContainer(
              duration: _duration,
              color: isDarkMode ? _nightTrack : _dayTrack,
              child: Stack(
                children: [
                  // Estrellas (visibles solo de noche).
                  Positioned.fill(
                    child: AnimatedOpacity(
                      duration: _duration,
                      opacity: isDarkMode ? 1 : 0,
                      child: const Stack(
                        children: [
                          Positioned(left: 42.5, top: 8.5, child: _Star()),
                          Positioned(left: 37.4, top: 20.4, child: _Star()),
                          Positioned(left: 51.0, top: 15.3, child: _Star()),
                        ],
                      ),
                    ),
                  ),
                  // Nube (visible solo de día). CSS: left: -1.1em;
                  // bottom: -1.4em; width: 3.5em (viewBox 16x16 cuadrado).
                  Positioned(
                    left: -18.7,
                    bottom: -23.8,
                    width: 59.5,
                    height: 59.5,
                    child: AnimatedOpacity(
                      duration: _duration,
                      opacity: isDarkMode ? 0 : 1,
                      child: const CustomPaint(painter: _CloudPainter()),
                    ),
                  ),
                  // Círculo desplazable (luna <-> sol).
                  AnimatedPositioned(
                    duration: _duration,
                    curve: _knobCurve,
                    left: isDarkMode ? _margin : _margin + _travel,
                    top: _margin,
                    child: SizedBox(
                      width: _knobSize,
                      height: _knobSize,
                      child: Stack(
                        children: [
                          // Sol (día): disco amarillo sólido.
                          AnimatedOpacity(
                            duration: _duration,
                            opacity: isDarkMode ? 0 : 1,
                            child: const SizedBox(
                              width: _knobSize,
                              height: _knobSize,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _sunColor,
                                ),
                              ),
                            ),
                          ),
                          // Luna (noche): creciente blanco exacto del CSS
                          // (box-shadow: inset 8px -4px 0px 0px #fff).
                          AnimatedOpacity(
                            duration: _duration,
                            opacity: isDarkMode ? 1 : 0,
                            child: const CustomPaint(
                              size: Size(_knobSize, _knobSize),
                              painter: _MoonPainter(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Star extends StatelessWidget {
  const _Star();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
    );
  }
}

/// Luna: réplica exacta de `box-shadow: inset 8px -4px 0px 0px #fff`
/// sobre el disco transparente del CSS — el "hueco" (círculo desplazado
/// +8px, -4px) se resta al disco y solo queda el creciente blanco.
class _MoonPainter extends CustomPainter {
  const _MoonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final disc = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    final hole = Path()
      ..addOval(
        Rect.fromCircle(center: center.translate(8, -4), radius: radius),
      );
    canvas.drawPath(
      Path.combine(PathOperation.difference, disc, hole),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _MoonPainter oldDelegate) => false;
}

/// Nube: trazado SVG original de Uiverse (JustCode14) con su matriz
/// `matrix(.77976 0 0 .78395 -299.99 -418.63)` y viewBox `0 0 16 16`.
class _CloudPainter extends CustomPainter {
  const _CloudPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // viewBox 0 0 16 16 -> píxeles reales (preserveAspectRatio: meet).
    final k = size.shortestSide / 16;

    // La matriz SVG matrix(.77976 0 0 .78395 -299.99 -418.63) es solo
    // escala + traslación: se aplica directamente a las coordenadas
    // (Path.transform resultó no-op, por eso se hornea aquí).
    double x(double v) => (0.77976 * v - 299.99) * k;
    double y(double v) => (0.78395 * v - 418.63) * k;
    double rx(double v) => 0.77976 * v * k; // deltas: sin traslación
    double ry(double v) => 0.78395 * v * k;

    final path = Path()
      ..moveTo(x(391.84), y(540.91))
      ..relativeCubicTo(
          rx(-0.421), ry(-0.329), rx(-0.949), ry(-0.524), rx(-1.523), ry(-0.524))
      ..relativeCubicTo(
          rx(-1.351), ry(0), rx(-2.451), ry(1.084), rx(-2.485), ry(2.435))
      ..relativeCubicTo(
          rx(-1.395), ry(0.526), rx(-2.388), ry(1.88), rx(-2.388), ry(3.466))
      ..relativeCubicTo(
          rx(0), ry(1.874), rx(1.385), ry(3.423), rx(3.182), ry(3.667))
      ..relativeLineTo(rx(0), ry(0.034))
      ..relativeLineTo(rx(12.73), ry(0))
      ..relativeLineTo(rx(0), ry(-0.006))
      ..relativeCubicTo(
          rx(1.775), ry(-0.104), rx(3.182), ry(-1.584), rx(3.182), ry(-3.395))
      ..relativeCubicTo(
          rx(0), ry(-1.747), rx(-1.309), ry(-3.186), rx(-2.994), ry(-3.379))
      ..relativeCubicTo(
          rx(0.007), ry(-0.106), rx(0.011), ry(-0.214), rx(0.011), ry(-0.322))
      ..relativeCubicTo(
          rx(0), ry(-2.707), rx(-2.271), ry(-4.901), rx(-5.072), ry(-4.901))
      ..relativeCubicTo(
          rx(-2.073), ry(0), rx(-3.856), ry(1.202), rx(-4.643), ry(2.925))
      ..close();

    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) => false;
}
