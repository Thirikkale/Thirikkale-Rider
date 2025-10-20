import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class RideTypeTabs extends StatelessWidget {
  final ValueChanged<int>? onTabChanged;
  final int selectedIndex;

  const RideTypeTabs({
    super.key,
    this.onTabChanged,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        children: [
          _buildTab(context, 0, 'Solo', 'assets/icons/vehicles/solo_car.png'),
          _buildTab(context, 1, 'Shared', 'assets/icons/vehicles/shared_car.png'),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index, String title, String iconPath) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          onTabChanged?.call(index);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(iconPath, width: 40, height: 40),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: AppTextStyles.bodyXLarge.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w900 : FontWeight.w600,
                      color:
                          isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 2,
              color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
