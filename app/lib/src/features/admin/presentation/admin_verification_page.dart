import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/design_system.dart';
import '../../../theme/components/app_colors.dart';
import '../../../theme/components/app_text_styles.dart';
import '../../pandit_onboarding/domain/pandit_profile.dart';
import '../data/admin_repository_provider.dart';

class AdminVerificationPage extends ConsumerWidget {
  const AdminVerificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingPanditsProvider);

    return AppScaffold(
      title: 'Verification Portal',
      body: pendingAsync.when(
        data: (pandits) => pandits.isEmpty
            ? const Center(child: Text('No pending applications found.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pandits.length,
                itemBuilder: (context, index) {
                  final pandit = pandits[index] as PanditProfile;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _PanditVerificationCard(pandit: pandit),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _PanditVerificationCard extends ConsumerWidget {
  final PanditProfile pandit;
  const _PanditVerificationCard({required this.pandit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PrimaryCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: pandit.profileImageUrl != null
                      ? NetworkImage(pandit.profileImageUrl!)
                      : null,
                  backgroundColor: AppColors.saffron.withOpacity(0.1),
                  child: pandit.profileImageUrl == null
                      ? const Icon(Icons.person, color: AppColors.saffron)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${pandit.firstName} ${pandit.lastName}',
                          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                      Text(pandit.emailAddress ?? 'No Email', style: AppTextStyles.bodySmall),
                      Text('Exp: ${pandit.experienceYears} Years', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('PENDING',
                      style: TextStyle(color: Colors.orange.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 32),
            Text('Aadhar Number: ${pandit.aadharNumber}', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 4),
            Text('Address: ${pandit.addressLine1 ?? "N/A"}', style: AppTextStyles.bodySmall),
            if (pandit.addressLine2 != null && pandit.addressLine2!.isNotEmpty)
              Text('Address Line 2: ${pandit.addressLine2}', style: AppTextStyles.bodySmall),
            Text('City: ${pandit.city ?? "N/A"}, State: ${pandit.state ?? "N/A"}', style: AppTextStyles.bodySmall),
            Text('Pin Code: ${pandit.pinCode ?? "N/A"}', style: AppTextStyles.bodySmall),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            Row(
              children: [
                if (pandit.aadharFrontUrl != null)
                  Expanded(
                    child: _buildAadharImage(context, 'Front Side', pandit.aadharFrontUrl!),
                  ),
                if (pandit.aadharBackUrl != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildAadharImage(context, 'Back Side', pandit.aadharBackUrl!),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(ref, pandit.id, PanditVerificationStatus.rejected),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(ref, pandit.id, PanditVerificationStatus.verified),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAadharImage(BuildContext context, String label, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _showImageDialog(context, url),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              image: DecorationImage(
                image: NetworkImage(url),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.zoom_in, color: Colors.white, size: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showImageDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Image.network(url),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(WidgetRef ref, String id, PanditVerificationStatus status) async {
    try {
      await ref.read(adminRepositoryProvider).updateStatus(id, status);
      ref.invalidate(pendingPanditsProvider);
    } catch (e) {
      // Handle error
    }
  }
}
