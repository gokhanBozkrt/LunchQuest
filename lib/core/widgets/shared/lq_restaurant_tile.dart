import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';
import '../../../features/home/domain/entities/restaurant.dart';

class LqRestaurantTile extends StatelessWidget {
  final Restaurant restaurant;
  final double size;
  final double radius;

  const LqRestaurantTile({
    super.key,
    required this.restaurant,
    this.size = 48,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color(restaurant.tileColor),
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Text(
        restaurant.name[0],
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
