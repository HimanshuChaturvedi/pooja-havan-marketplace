import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/home_booking/presentation/widgets/action_card.dart';
import 'package:app/src/features/home_booking/presentation/widgets/banner_carousel.dart';
import 'package:app/src/features/booking/application/booking_session.dart';
import 'package:app/src/features/samagri_flow/application/samagri_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/src/features/samagri_flow/state/samagri_cart_notifier.dart';
import 'package:app/src/features/main/presentation/state/main_navigation_provider.dart';

class HomeScreen extends ConsumerWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.warmIvory,
      child: Stack(
        children: [
          // 🏠 MAIN SCROLLABLE CONTENT
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 90), 

                    // 🏷️ HERO QUESTION
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'What would you\nlike to do?',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          color: AppColors.darkCharcoal,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24), // 24px Section Gap

                    // 🧩 PRIMARY ACTION GRID
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.92,
                        children: [
                          ActionCard(
                            title: 'Book a Pooja',
                            subtitle: 'Divine rituals at home',
                            icon: Icons.temple_hindu_rounded,
                            onTap: () {
                              ref.read(mainNavigationProvider.notifier).state = 0; // Home tab
                              BookingSession.reset();
                              SamagriSession.clear();
                              ref.read(samagriCartProvider.notifier).clearCart();
                              context.push('/services');
                            },
                          ),
                          ActionCard(
                            title: 'Explore Services',
                            subtitle: 'Sacred experiences',
                            icon: Icons.explore_outlined,
                            onTap: () => context.push('/explore-services'),
                          ),
                          ActionCard(
                            title: 'Shop',
                            subtitle: 'Pure ritual essentials',
                            icon: Icons.shopping_basket_rounded,
                            onTap: () {
                              ref.read(mainNavigationProvider.notifier).state = 2; // Shop tab
                              BookingSession.reset();
                              SamagriSession.clear();
                              ref.read(samagriCartProvider.notifier).clearCart();
                              // Simply going to landing will now show index 2
                              context.go('/landing');
                            },
                          ),
                          ActionCard(
                            title: 'Temple Services',
                            subtitle: 'Book rituals at temple',
                            icon: Icons.account_balance_rounded,
                            onTap: () {
                              ref.read(mainNavigationProvider.notifier).state = 0; // Home tab
                              BookingSession.reset();
                              SamagriSession.clear();
                              ref.read(samagriCartProvider.notifier).clearCart();
                              context.push('/temple-services');
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 🎡 UPCOMING FESTIVALS SECTION
                    Text(
                      'Upcoming Festivals',
                      style: AppTextStyles.title.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const BannerCarousel(),
                    
                    const SizedBox(height: 24),

                    // 🏛️ TEMPLE BOOKING BANNER
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.saffron.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.account_balance_rounded, color: AppColors.saffron, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Temple Booking Now Available',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.darkCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Reserve your sacred visit in advance',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.softGrey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),

          // 🏗️ CLEAN HEADER
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 📍 LOCATION SELECTOR
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push('/location-selection?type=home'),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: AppColors.saffron, size: 22),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Location',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.softGrey,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Ghaziabad',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          color: AppColors.darkCharcoal,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.softGrey, size: 18),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 🔔 ICONS SECTIONS
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: AppColors.darkCharcoal, size: 26),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 4),
                  const AvatarWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/profile'),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.warmIvory, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
            ),
          ],
        ),
        child: const CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.saffron,
          child: Icon(Icons.person_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
