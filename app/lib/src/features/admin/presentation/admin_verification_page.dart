import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/design_system.dart';
import '../../../theme/components/app_colors.dart';
import '../../../theme/components/app_text_styles.dart';
import '../../pandit_onboarding/domain/pandit_profile.dart';
import '../data/admin_repository_provider.dart';

class AdminVerificationPage extends ConsumerStatefulWidget {
  const AdminVerificationPage({super.key});

  @override
  ConsumerState<AdminVerificationPage> createState() => _AdminVerificationPageState();
}

class _AdminVerificationPageState extends ConsumerState<AdminVerificationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Verification Portal',
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.saffron,
            unselectedLabelColor: AppColors.softGrey,
            indicatorColor: AppColors.saffron,
            tabs: const [
              Tab(text: 'Pandits'),
              Tab(text: 'Vendors'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PanditListTab(),
                _VendorListTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PanditListTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_PanditListTab> createState() => _PanditListTabState();
}

class _PanditListTabState extends ConsumerState<_PanditListTab> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final provider = _showAll ? allPanditsProvider : pendingPanditsProvider;
    final asyncValue = ref.watch(provider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilterChip(
                label: Text(_showAll ? 'Showing All' : 'Showing Pending'),
                selected: _showAll,
                onSelected: (v) => setState(() => _showAll = v),
                selectedColor: AppColors.saffron.withOpacity(0.2),
                checkmarkColor: AppColors.saffron,
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(pendingPanditsProvider);
              ref.invalidate(allPanditsProvider);
            },
            color: AppColors.saffron,
            child: asyncValue.when(
              data: (pandits) => pandits.isEmpty
                  ? Center(child: Text(_showAll ? 'No Pandits found.' : 'No pending Pandits found.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      physics: const AlwaysScrollableScrollPhysics(),
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
          ),
        ),
      ],
    );
  }
}

class _VendorListTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_VendorListTab> createState() => _VendorListTabState();
}

class _VendorListTabState extends ConsumerState<_VendorListTab> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final provider = _showAll ? allVendorsProvider : pendingVendorsProvider;
    final asyncValue = ref.watch(provider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilterChip(
                label: Text(_showAll ? 'Showing All' : 'Showing Pending'),
                selected: _showAll,
                onSelected: (v) => setState(() => _showAll = v),
                selectedColor: AppColors.saffron.withOpacity(0.2),
                checkmarkColor: AppColors.saffron,
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(pendingVendorsProvider);
              ref.invalidate(allVendorsProvider);
            },
            color: AppColors.saffron,
            child: asyncValue.when(
              data: (vendors) => vendors.isEmpty
                  ? Center(child: Text(_showAll ? 'No vendors found.' : 'No pending Vendors found.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: vendors.length,
                      itemBuilder: (context, index) {
                        final vendor = vendors[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _VendorVerificationCard(vendor: vendor),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, __) => Center(child: Text('Error: $e')),
            ),
          ),
        ),
      ],
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
                      Text('Email: ${pandit.emailAddress ?? "No Email"}', style: AppTextStyles.bodySmall),
                      Text('Phone: ${pandit.phoneNumber.isNotEmpty ? pandit.phoneNumber : "Not Available"}', style: AppTextStyles.bodySmall),
                      Text('Experience: ${pandit.experienceYears} Years', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                _buildStatusBadge(pandit.verificationStatus),
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
            if (pandit.verificationStatus == PanditVerificationStatus.pending)
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
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(ref, pandit.id, PanditVerificationStatus.pending),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                      child: const Text('Move to Pending'),
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

  Widget _buildStatusBadge(PanditVerificationStatus status) {
    Color color = Colors.orange;
    if (status == PanditVerificationStatus.verified) color = Colors.green;
    if (status == PanditVerificationStatus.rejected) color = Colors.red;

    return _Badge(label: 'PANDIT ${status.name.toUpperCase()}', color: color);
  }

  Future<void> _updateStatus(WidgetRef ref, String id, PanditVerificationStatus status) async {
    try {
      await ref.read(adminRepositoryProvider).updateStatus(id, status);
      ref.invalidate(pendingPanditsProvider);
      ref.invalidate(allPanditsProvider);
      
      if (ref.context.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(content: Text('Pandit status updated to ${status.name.toUpperCase()}')),
        );
      }
    } catch (e) {
      if (ref.context.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _VendorVerificationCard extends ConsumerWidget {
  final Map<String, dynamic> vendor;
  const _VendorVerificationCard({required this.vendor});

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
                  radius: 24,
                  backgroundColor: AppColors.saffron.withOpacity(0.1),
                  child: const Icon(Icons.store, color: AppColors.saffron),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vendor['shop_name'] ?? 'Unknown Shop',
                          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                      Text('Phone: ${vendor['phone_number']}', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                _buildStatusBadge(vendor['verification_status'] ?? 'PENDING'),
              ],
            ),
            const Divider(height: 32),
            Text('Coordinates:', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
            Text('Lat: ${vendor['latitude']}, Lon: ${vendor['longitude']}', style: AppTextStyles.bodySmall),
            const SizedBox(height: 8),
            Text('Address: ${vendor['address'] ?? "N/A"}', style: AppTextStyles.bodySmall),
            const SizedBox(height: 8),
            Text('Delivery Radius: ${vendor['delivery_radius_km']} km', style: AppTextStyles.bodySmall),
            const SizedBox(height: 24),
            if ((vendor['verification_status'] as String).toUpperCase() == 'PENDING')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateVendorStatus(ref, vendor['id'], 'REJECTED'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateVendorStatus(ref, vendor['id'], 'VERIFIED'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateVendorStatus(ref, vendor['id'], 'PENDING'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                      child: const Text('Move to Pending'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    status = status.toUpperCase();
    Color color = Colors.orange;
    if (status == 'VERIFIED') color = Colors.green;
    if (status == 'REJECTED') color = Colors.red;

    return _Badge(label: 'VENDOR $status', color: color);
  }

  Future<void> _updateVendorStatus(WidgetRef ref, String id, String status) async {
    try {
      await ref.read(adminRepositoryProvider).updateVendorStatus(id, status);
      ref.invalidate(pendingVendorsProvider);
      ref.invalidate(allVendorsProvider);

      if (ref.context.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(content: Text('Vendor status updated to $status')),
        );
      }
    } catch (e) {
      if (ref.context.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}
