import 'package:flutter/material.dart';
import 'package:app/src/features/home_booking/presentation/home_screen.dart';
import 'package:app/src/core/widgets/glass_bottom_nav.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/features/bookings/presentation/my_bookings_page.dart';
import 'package:app/src/features/samagri_flow/presentation/list/samagri_list_page.dart';
import 'package:app/src/features/main/presentation/pages/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const MyBookingsPage(),
    const SamagriListPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.warmIvory,
      body: _pages[_selectedIndex],
      bottomNavigationBar: GlassBottomNav(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
