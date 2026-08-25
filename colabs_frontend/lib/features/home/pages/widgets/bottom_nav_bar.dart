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

  @override
  Widget build(BuildContext context) {
    return Container(
      height:     70,
      decoration: BoxDecoration(
        color: context.colors.surface,
        boxShadow: [
          BoxShadow(
            color:      context.colors.textSecondary.withOpacity(0.1),
            blurRadius: 10,
            offset:     const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon:     Icons.home_outlined,
            iconActive: Icons.home,
            index:    0,
            current:  currentIndex,
            onTap:    onTap,
          ),
          _NavItem(
            icon:     Icons.group_outlined,
            iconActive: Icons.group,
            index:    1,
            current:  currentIndex,
            onTap:    onTap,
          ),

          // Botón central — gota de agua
          GestureDetector(
            onTap: () => onTap(2),
            child: _WaterDropButton(isActive: currentIndex == 2),
          ),

          _NavItem(
            icon:     Icons.checklist_outlined,
            iconActive: Icons.checklist,
            index:    3,
            current:  currentIndex,
            onTap:    onTap,
          ),
          _NavItem(
            icon:     isColaborador
                ? Icons.assignment_outlined
                : Icons.favorite_outline,
            iconActive: isColaborador
                ? Icons.assignment
                : Icons.favorite,
            index:    4,
            current:  currentIndex,
            onTap:    onTap,
          ),
        ],
      ),
    );
  }
}

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:  const EdgeInsets.all(8),
        child: Icon(
          isActive ? iconActive : icon,
          color: isActive
              ? Theme.of(context).iconTheme.color
              : context.colors.textSecondary,
          size:  26,
        ),
      ),
    );
  }
}

class _WaterDropButton extends StatelessWidget {
  final bool isActive;

  const _WaterDropButton({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  58,
      height: 58,
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: const BorderRadius.only(
          topLeft:     Radius.circular(50),
          topRight:    Radius.circular(50),
          bottomLeft:  Radius.circular(50),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color:      context.colors.primary.withOpacity(0.4),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.search,
        color: Colors.white,
        size:  26,
      ),
    );
  }
}