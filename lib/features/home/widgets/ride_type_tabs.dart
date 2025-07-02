import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class RideTypeTabs extends StatefulWidget {
  const RideTypeTabs({super.key});

  @override
  State<RideTypeTabs> createState() => _RideTypeTabsState();
}

class _RideTypeTabsState extends State<RideTypeTabs> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        children: [
          _buildTab(0, 'Solo', 'assets/icons/vehicles/solo_car.png'),
          _buildTab(1, 'Shared', 'assets/icons/vehicles/shared_car.png'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title, String iconPath) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
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
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
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
