import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ColabsBottomNav extends StatelessWidget {
  final int              currentIndex;
  final ValueChanged<int> onTap;
  final bool isColaborador;

  const ColabsBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isColaborador,
  });

  // Dimensiones del diseño
  static const double _barHeight     = 74; //Altura de la barra
  static const double _notchWidth    = 90; //Ancho de la curva
  static const double _notchDepth    = 33; //profundidad de la curva
  static const double _bubbleSize    = 68; //diametro de la burbuja central
  static const double _gap           = -25; //espacio entre la barra y la burbuja central
  static const double _cornerRadius  = 17; //radio de las esquinas superiores de la barra

  @override
  Widget build(BuildContext context) {
    final barColor  = context.colors.navBarBackground;
    final bubbleColor = context.colors.navBarBubble;
    final stackHeight = _barHeight + _gap + _bubbleSize;

    return SizedBox(
      height: stackHeight,
      width:  double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Barra con muesca cóncava + esquinas superiores redondeadas
          Positioned(
            left:   0,
            right:  0,
            bottom: 0,
            height: _barHeight,
            child: CustomPaint(
              size: Size.infinite,
              painter: _ConcaveBarPainter(
                color:        barColor,
                notchWidth:   _notchWidth,
                notchDepth:   _notchDepth,
                cornerRadius: _cornerRadius,
              ),
            ),
          ),

          // Iconos de navegación dentro de la barra
          Positioned(
            left:   0,
            right:  0,
            bottom: 0,
            height: _barHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _NavItem(
                  icon:      Icons.home_outlined,
                  iconActive: Icons.home,
                  index:     0,
                  current:   currentIndex,
                  onTap:     onTap,
                ),
                _NavItem(
                  icon:      Icons.group_outlined,
                  iconActive: Icons.group,
                  index:     1,
                  current:   currentIndex,
                  onTap:     onTap,
                ),

                // Reserva el espacio de la muesca central
                const SizedBox(width: _notchWidth),

                _NavItem(
                  icon:      Icons.checklist_outlined,
                  iconActive: Icons.checklist,
                  index:     3,
                  current:   currentIndex,
                  onTap:     onTap,
                ),
                _NavItem(
                  icon:      isColaborador
                      ? Icons.assignment_outlined
                      : Icons.favorite_outline,
                  iconActive: isColaborador
                      ? Icons.assignment
                      : Icons.favorite,
                  index:     4,
                  current:   currentIndex,
                  onTap:     onTap,
                ),
              ],
            ),
          ),

          // Burbuja central flotante
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _FloatingBubble(
                color:    bubbleColor,
                size:     _bubbleSize,
                onTap: () => onTap(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pinta la barra con esquinas superiores redondeadas y una muesca cóncava
/// (curva hacia abajo) perfectamente suave en el centro.
class _ConcaveBarPainter extends CustomPainter {
  final Color color;
  final double notchWidth;
  final double notchDepth;
  final double cornerRadius;

  _ConcaveBarPainter({
    required this.color,
    required this.notchWidth,
    required this.notchDepth,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerX = w / 2;
    final notchLeft  = centerX - (notchWidth / 2);
    final notchRight = centerX + (notchWidth / 2);

    final path = Path()
      ..moveTo(0, h)
      // Lateral inferior-izquierdo
      ..lineTo(0, cornerRadius)
      // Esquina superior izquierda redondeada
      ..quadraticBezierTo(0, 0, cornerRadius, 0)
      // Hasta el inicio de la muesca
      ..lineTo(notchLeft, 0)
      // Muesca cóncava (curva hacia abajo, orgánica y suave)
      ..quadraticBezierTo(centerX, 2 * notchDepth, notchRight, 0)
      // Hasta la esquina superior derecha
      ..lineTo(w - cornerRadius, 0)
      // Esquina superior derecha redondeada
      ..quadraticBezierTo(w, 0, w, cornerRadius)
      // Lateral inferior-derecho
      ..lineTo(w, h)
      ..close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Sombra sutil superior para despegar la barra del contenido
    canvas.save();
    canvas.drawShadow(path, Colors.black26, 8, true);
    canvas.restore();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ConcaveBarPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.notchWidth != notchWidth ||
        oldDelegate.notchDepth != notchDepth ||
        oldDelegate.cornerRadius != cornerRadius;
  }
}

/// Ícono de navegación con estado activo (relleno + línea indicadora).
class _NavItem extends StatelessWidget {
  final IconData          icon;
  final IconData          iconActive;
  final int               index;
  final int               current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.iconActive,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:  const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? iconActive : icon,
              color: isActive
                  ? Theme.of(context).iconTheme.color
                  : context.colors.textSecondary,
              size: 26,
            ),
            const SizedBox(height: 3),
            // Línea indicadora de estado activo
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width:  isActive ? 22 : 0,
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? context.colors.navBarBubble : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Burbuja central flotante, circular perfecta.
class _FloatingBubble extends StatelessWidget {
  final Color    color;
  final double   size;
  final VoidCallback onTap;

  const _FloatingBubble({
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:      color.withOpacity(0.45),
              blurRadius: 14,
              offset:     const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          Icons.search,
          color: Colors.white,
          size:  28,
        ),
      ),
    );
  }
}
