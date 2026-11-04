import 'package:flutter/material.dart';
import '../../../../widgets/app_skeleton.dart';

import '../../../../constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../routes/app_router.dart';
import 'end_of_day_shared.dart';

class EndOfDayEmptyState extends StatelessWidget {
  const EndOfDayEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return EndOfDayCard(
      child: SizedBox(
        height: 420,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 118,
              height: 118,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF7EC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.manage_search_rounded,
                color: Color(0xFF0D7A24),
                size: 58,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'No active loading session',
              textAlign: TextAlign.center,
              style: AppTextStyles.cardTitle,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 260,
              child: Text(
                'You need to record an opening load before you can do end of day return.',
                textAlign: TextAlign.center,
                style: AppTextStyles.secondary,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 250,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.deliveryVehicleLoading);
                },
                icon: const Icon(Icons.local_shipping_outlined, size: 18),
                label: const Text('Go to Vehicle Loading'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EndOfDayLoadingState extends StatelessWidget {
  const EndOfDayLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EndOfDayCard(child: AppPageSkeleton(rows: 5));
  }
}
