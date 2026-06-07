import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/src/core/supabase/supabase_client.dart';
import 'package:app/src/core/widgets/design_system.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/auth/presentation/state/auth_provider_impl.dart';

class NotificationsSettingsPage extends ConsumerStatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  ConsumerState<NotificationsSettingsPage> createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends ConsumerState<NotificationsSettingsPage> {
  bool _whatsappBookings = true;
  bool _offersPromos = true;
  bool _rashifalTips = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = supabase.auth.currentUser;
    final metadata = user?.userMetadata ?? {};
    final prefs = metadata['notification_preferences'] as Map<dynamic, dynamic>? ?? {};

    _whatsappBookings = prefs['whatsapp_bookings'] ?? true;
    _offersPromos = prefs['offers'] ?? true;
    _rashifalTips = prefs['rashifal'] ?? true;
  }

  Future<void> _updatePreference(String key, bool value) async {
    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      final metadata = user?.userMetadata ?? {};
      final prefs = Map<String, dynamic>.from(metadata['notification_preferences'] as Map? ?? {});
      
      prefs[key] = value;

      await supabase.auth.updateUser(
        UserAttributes(
          data: {
            'notification_preferences': prefs,
          },
        ),
      );

      // Sync state throughout the app
      ref.invalidate(supabaseUserProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update preference: $e')),
        );
      }
      // Revert local state
      setState(() {
        if (key == 'whatsapp_bookings') _whatsappBookings = !_whatsappBookings;
        if (key == 'offers') _offersPromos = !_offersPromos;
        if (key == 'rashifal') _rashifalTips = !_rashifalTips;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Notifications',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sacred Alerts 🙏',
              style: AppTextStyles.title.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Customize how and when you receive details about your sacred ceremonies.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey),
            ),
            const SizedBox(height: 32),

            // WHATSAPP BOOKING UPDATES
            _NotificationToggleTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'WhatsApp Booking Updates',
              subtitle: 'Receive booking status, Pandit partner details, and Samagri list directly on WhatsApp.',
              value: _whatsappBookings,
              onChanged: (val) {
                setState(() => _whatsappBookings = val);
                _updatePreference('whatsapp_bookings', val);
              },
            ),

            const SizedBox(height: 20),

            // OFFERS & PROMOS
            _NotificationToggleTile(
              icon: Icons.local_offer_outlined,
              title: 'Festive Offers & Discounts',
              subtitle: 'Stay updated about special festival discounts, customized pooja categories, and auspicious days.',
              value: _offersPromos,
              onChanged: (val) {
                setState(() => _offersPromos = val);
                _updatePreference('offers', val);
              },
            ),

            const SizedBox(height: 20),

            // RASHIFAL & SPIRITUAL INSIGHTS
            _NotificationToggleTile(
              icon: Icons.auto_awesome_outlined,
              title: 'Rashifal & Spiritual Wisdom',
              subtitle: 'Receive weekly horoscopes, auspicious panchang timings, and sacred spiritual tips.',
              value: _rashifalTips,
              onChanged: (val) {
                setState(() => _rashifalTips = val);
                _updatePreference('rashifal', val);
              },
            ),

            if (_isLoading) ...[
              const SizedBox(height: 40),
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.saffron),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.saffron.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.saffron, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkCharcoal,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.softGrey,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.saffron,
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }
}
