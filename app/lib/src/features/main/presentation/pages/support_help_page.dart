import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/src/core/widgets/design_system.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';

class SupportHelpPage extends StatefulWidget {
  const SupportHelpPage({super.key});

  @override
  State<SupportHelpPage> createState() => _SupportHelpPageState();
}

class _SupportHelpPageState extends State<SupportHelpPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I book a Pooja ceremony?',
      'answer': 'Browse our offerings from the home tab, select your desired Pooja (e.g. Satyanarayan Pooja, Griha Pravesh), choose "At Home" or "At Temple" mode, pick a date, choose a verified Pandit partner, select if you want complete Samagri, and confirm via secure payment.'
    },
    {
      'question': 'Is Pooja Samagri included in the price?',
      'answer': 'When booking, you can choose whether to include Samagri. If you choose to include it, our local verified vendor partners will package high-quality, properly purified items and deliver them to your address 1 day before the ceremony.'
    },
    {
      'question': 'Can I choose a specific Pandit partner?',
      'answer': 'Yes! After selecting your date and booking mode, our app displays verified Pandit partners specializing in your ceremony. You can view their profiles, review their experience, and select your preferred Pandit.'
    },
    {
      'question': 'How do I cancel or reschedule a booking?',
      'answer': 'To cancel or reschedule a ceremony, simply drop us a message on WhatsApp or email us at bharatpoojasetu@gmail.com at least 24 hours before the scheduled time. Our support team will instantly process your request.'
    },
    {
      'question': 'What is your refund policy?',
      'answer': 'Full refunds are processed directly to your original payment method for cancellations made at least 24 hours before the scheduled ceremony time. Refunds usually take 5-7 business days to reflect.'
    }
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open: $urlString')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _faqs.where((faq) {
      final query = _searchQuery.toLowerCase();
      return faq['question']!.toLowerCase().contains(query) ||
             faq['answer']!.toLowerCase().contains(query);
    }).toList();

    return AppScaffold(
      title: 'Support & Help',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sacred Support Portal 🙏',
              style: AppTextStyles.title.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We are here to assist you in making your spiritual journey and ritual bookings seamless.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey),
            ),
            const SizedBox(height: 32),

            // QUICK SUPPORT OPTIONS
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // WHATSAPP CARD
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _launchUrl('https://wa.me/918287966676'),
                      child: PrimaryCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.saffron.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.saffron, size: 24),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Chat on WhatsApp',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Instant chat help for bookings & Pandit partners.',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // EMAIL CARD
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _launchUrl('mailto:bharatpoojasetu@gmail.com'),
                      child: PrimaryCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.saffron.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.email_outlined, color: AppColors.saffron, size: 24),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Email Support',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Write to us for receipt, refunds or custom poojas.',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // FAQ HEADER & SEARCH
            const SectionHeader(title: 'Frequently Asked Questions'),
            const SizedBox(height: 12),
            PrimaryCard(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  hintText: 'Search queries, refund, samagri...',
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.saffron),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // FAQ LIST
            filteredFaqs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'No matching FAQs found.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredFaqs.length,
                    itemBuilder: (context, index) {
                      final faq = filteredFaqs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            expansionTileTheme: const ExpansionTileThemeData(
                              iconColor: AppColors.saffron,
                              collapsedIconColor: AppColors.softGrey,
                            ),
                          ),
                          child: PrimaryCard(
                            padding: EdgeInsets.zero,
                            child: ExpansionTile(
                              title: Text(
                                faq['question']!,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.darkCharcoal,
                                ),
                              ),
                              children: [
                                const Divider(height: 1, color: Colors.black12),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    faq['answer']!,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.softGrey,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
