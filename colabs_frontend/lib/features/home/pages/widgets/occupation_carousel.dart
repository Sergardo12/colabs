import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class OccupationCarousel extends StatelessWidget {
  const OccupationCarousel({super.key});

  // Placeholder hasta que tengamos el endpoint de ocupaciones
  static const List<Map<String, dynamic>> _occupations = [
    {'name': 'Electricidad', 'color': Color(0xFF1E41BC)},
    {'name': 'Carpintería',  'color': Color(0xFF017DB0)},
    {'name': 'Gasfitería',   'color': Color(0xFF0D5C8A)},
    {'name': 'Repostería',   'color': Color(0xFF6B3FA0)},
    {'name': 'Jardinería',   'color': Color(0xFF2E7D32)},
    {'name': 'Pintura',      'color': Color(0xFFE65100)},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection:  Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL,
          vertical:   AppSizes.paddingS,
        ),
        itemCount:    _occupations.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppSizes.paddingS),
        itemBuilder: (context, index) {
          final occupation = _occupations[index];
          return _OccupationItem(
            name:  occupation['name']  as String,
            color: occupation['color'] as Color,
          );
        },
      ),
    );
  }
}

class _OccupationItem extends StatelessWidget {
  final String name;
  final Color  color;

  const _OccupationItem({
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color:        color,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Stack(
        children: [
          // Círculo decorativo
          Positioned(
            right:  -10,
            bottom: -10,
            child:  Container(
              width:  60,
              height: 60,
              decoration: BoxDecoration(
                color:  Colors.white.withOpacity(0.1),
                shape:  BoxShape.circle,
              ),
            ),
          ),

          // Nombre de la ocupación
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingS),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                name,
                style: TextStyle(
                  color:      context.colors.white,
                  fontSize:   AppSizes.fontM,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}