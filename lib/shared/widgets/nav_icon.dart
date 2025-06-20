import 'package:flutter/material.dart';
import '../../core/theme/icon_sizes.dart';
import '../../core/theme/app_colors.dart';

class NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const NavIcon({
    super.key,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    final iconColor = isSelected ? colors.brandPrimary : colors.subdued;

    return Container(
      height: 40,
      width: 80, //pill width
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected
            ? colors.brandPrimary.withOpacity(0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(
        icon,
        size: isSelected ? IconSizes.navSelected : IconSizes.navUnselected,
        color: iconColor,
      ),
    );
  }
}
