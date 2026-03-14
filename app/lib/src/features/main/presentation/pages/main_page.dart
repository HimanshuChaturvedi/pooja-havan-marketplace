import 'package:flutter/material.dart';
import 'package:app/src/features/landing/presentation/landing_enhanced_page.dart';
import 'package:app/src/core/widgets/glass_bottom_nav.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/features/bookings/presentation/my_bookings_page.dart';
import 'package:app/src/features/samagri_flow/presentation/list/samagri_list_page.dart';
import 'package:app/src/features/main/presentation/pages/profile_page.dart';

import 'package:app/src/features/main/presentation/state/main_navigation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  Widget _buildPage(int index) {
    switch (index) {
      case 0: return const LandingEnhancedPage();
      case 1: return const MyBookingsPage();  // ← mounts fresh on every tab switch
      case 2: return const SamagriListPage();
      case 3: return const ProfilePage();
      default: return const LandingEnhancedPage();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(mainNavigationProvider);

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.warmIvory,
      body: _buildPage(selectedIndex),
      bottomNavigationBar: GlassBottomNav(
        selectedIndex: selectedIndex,
        onItemSelected: (index) => ref.read(mainNavigationProvider.notifier).state = index,
      ),
    );
  }
}
