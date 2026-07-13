import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';
import '../data/vendor_repository.dart';
import '../state/vendor_order.dart';
import 'package:app/src/core/services/whatsapp_service.dart';
import 'package:app/src/core/utils/logger.dart';

class VendorDashboardPage extends ConsumerStatefulWidget {
  const VendorDashboardPage({super.key});

  @override
  ConsumerState<VendorDashboardPage> createState() => _VendorDashboardPageState();
}

class _VendorDashboardPageState extends ConsumerState<VendorDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(vendorOrdersProvider);

    return AppScaffold(
      title: 'Shop Dashboard',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.saffron),
          onPressed: () {
            ref.refresh(vendorOrdersProvider);
            ref.refresh(unassignedOrdersProvider);
          },
        ),
      ],
      body: Column(
        children: [
          Consumer(builder: (context, ref, _) {
            final profileAsync = ref.watch(vendorProfileFutureProvider);
            return profileAsync.when(
              data: (profile) {
                final status = profile?['verification_status'] ?? 'PENDING';
                if (status == 'VERIFIED') return const SizedBox.shrink();
                
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.orange.withOpacity(0.1),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Verification Pending: You will start receiving orders once an admin approves your shop.',
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.orange.shade900, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            );
          }),
          const _StatusToggle(),
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                final activeStates = ['pending', 'accepted', 'out_for_delivery'];
                final pending = orders.where((o) => activeStates.contains(o.status.toLowerCase())).toList();
                final history = orders.where((o) => !activeStates.contains(o.status.toLowerCase())).toList();
                
                return ref.watch(unassignedOrdersProvider).when(
                  data: (unassigned) {
                    final unassignedCount = unassigned.length;
                    return Column(
                      children: [
                        Container(
                          color: Colors.white,
                          child: TabBar(
                            controller: _tabController,
                            labelColor: AppColors.saffron,
                            unselectedLabelColor: AppColors.softGrey,
                            indicatorColor: AppColors.saffron,
                            indicatorWeight: 3,
                            labelStyle: AppTextStyles.button.copyWith(fontWeight: FontWeight.w800),
                            tabs: [
                              Tab(text: 'Open ($unassignedCount)'),
                              Tab(text: 'Active (${pending.length})'),
                              Tab(text: 'History (${history.length})'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _UnassignedOrderList(orders: unassigned, onRefresh: () {
                                ref.refresh(unassignedOrdersProvider);
                                ref.refresh(vendorOrdersProvider);
                              }),
                              _OrderList(orders: pending, onRefresh: () => ref.refresh(vendorOrdersProvider)),
                              _OrderList(orders: history, onRefresh: () => ref.refresh(vendorOrdersProvider)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Debug Error: $e')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffron)),
              error: (e, _) => Center(child: Text('Error loading orders: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderList extends ConsumerWidget {
  final List<VendorOrder> orders;
  final VoidCallback onRefresh;
  final String? emptyMessage;
  
  const _OrderList({required this.orders, required this.onRefresh, this.emptyMessage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.softGrey.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              emptyMessage ?? 'No orders found', 
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.softGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _OrderCard(order: order, onStatusUpdate: onRefresh);
      },
    );
  }
}

class _UnassignedOrderList extends ConsumerWidget {
  final List<VendorOrder> orders;
  final VoidCallback onRefresh;
  
  const _UnassignedOrderList({required this.orders, required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_basket_outlined, size: 64, color: AppColors.softGrey.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No Open Orders', 
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.softGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Orders without a nearby vendor will appear here.', 
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.softGrey.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _OrderCard(
          order: order, 
          onStatusUpdate: onRefresh,
          isUnassigned: true,
        );
      },
    );
  }
}

class _OrderCard extends ConsumerStatefulWidget {
  final VendorOrder order;
  final VoidCallback onStatusUpdate;
  final bool isUnassigned;

  const _OrderCard({
    required this.order, 
    required this.onStatusUpdate,
    this.isUnassigned = false,
  });

  @override
  ConsumerState<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends ConsumerState<_OrderCard> {
  bool _isUpdating = false;

  Future<void> _updateStatus(String status) async {
    setState(() => _isUpdating = true);
    try {
      if (widget.isUnassigned && status == 'accepted') {
        // Claim the order
        await ref.read(samagriVendorRepositoryProvider).claimOrder(widget.order.id);
      } else {
        await ref.read(samagriVendorRepositoryProvider).updateOrderStatus(widget.order.id, status);
      }
      widget.onStatusUpdate();
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _showRejectDialog() async {
    final List<String> reasons = [
      'Out of Stock',
      'Shop Closed',
      'Outside Delivery Area',
      'Busy',
      'Other'
    ];
    String selectedReason = reasons.first;
    final otherDetailsController = TextEditingController();
    bool isSubmitting = false;
    String? dialogError;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isOtherSelected = selectedReason == 'Other';

            Future<void> submitRejection() async {
              final details = otherDetailsController.text.trim();
              if (isOtherSelected && details.isEmpty) {
                setDialogState(() {
                  dialogError = 'Please provide details for "Other" reason';
                });
                return;
              }

              setDialogState(() {
                isSubmitting = true;
                dialogError = null;
              });

              try {
                // 1. Perform database reject update
                await ref.read(samagriVendorRepositoryProvider).rejectOrder(
                  widget.order.id,
                  selectedReason,
                  isOtherSelected ? details : null,
                );

                 // 2. Trigger Rejection WhatsApp notifications
                try {
                  final waService = ref.read(whatsappServiceProvider);
                  final reasonStr = isOtherSelected && details.isNotEmpty ? '$selectedReason ($details)' : selectedReason;
                  
                  // Alert Customer: customer phone is not in order model (Auth metadata scoped),
                  // so we use the default test number fallback
                  await waService.sendOrderRejectionToCustomer('+919871966676', reasonStr);

                  // Alert Admin:
                  await waService.sendOrderRejectionToAdmin(
                    orderRefId: widget.order.referenceId ?? widget.order.id.substring(0, 8),
                    reason: selectedReason,
                    details: isOtherSelected ? details : null,
                  );
                } catch (notifError) {
                  AppLogger.error('Failed to dispatch rejection WhatsApp notifications', notifError);
                }

                // 3. UI feedback & Dismiss
                if (mounted) {
                  Navigator.of(context).pop(); // Close dialog
                  widget.onStatusUpdate(); // Refresh dashboard list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order rejected successfully. 🙏'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                setDialogState(() {
                  isSubmitting = false;
                  dialogError = 'Failed to reject order: $e';
                });
              }
            }

            return AlertDialog(
              scrollable: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Reject Order',
                style: AppTextStyles.title.copyWith(fontSize: 18, color: Colors.red),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Please select a reason for rejecting this order:',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: reasons.map((reason) {
                      return DropdownMenuItem<String>(
                        value: reason,
                        child: Text(
                          reason, 
                          style: AppTextStyles.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: isSubmitting
                        ? null
                        : (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedReason = value;
                                dialogError = null;
                              });
                            }
                          },
                  ),
                  if (isOtherSelected) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: otherDetailsController,
                      enabled: !isSubmitting,
                      decoration: InputDecoration(
                        hintText: 'Please specify details...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      maxLines: 2,
                    ),
                  ],
                  if (dialogError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      dialogError!,
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.red, fontWeight: FontWeight.w700),
                    ),
                  ],
                ],
              ),
              actions: [
                OverflowBar(
                  alignment: MainAxisAlignment.end,
                  spacing: 8,
                  overflowSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                      child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.softGrey)),
                    ),
                    ElevatedButton(
                      onPressed: isSubmitting ? null : submitRejection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text('Reject', style: AppTextStyles.button.copyWith(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: PrimaryCard(
        padding: const EdgeInsets.all(20),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${widget.order.referenceId ?? widget.order.id.substring(0, 8)}',
                      style: AppTextStyles.title.copyWith(fontSize: 14, color: AppColors.saffron),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.order.bookingId == null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'DIRECT ORDER',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: Colors.blue.shade700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: widget.order.status),
            ],
          ),
          const SizedBox(height: 12),
          
          // Delivery Schedule
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: widget.order.deliveryDate != null ? AppColors.saffron.withOpacity(0.05) : Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  widget.order.deliveryDate != null ? Icons.calendar_today_rounded : Icons.bolt_rounded, 
                  size: 16, 
                  color: widget.order.deliveryDate != null ? AppColors.saffron : Colors.green
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.order.deliveryDate != null 
                      ? 'Delivery: ${widget.order.deliveryDate} at ${widget.order.deliveryTime ?? "Anytime"}'
                      : 'Express: Dispatch within 24h',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: widget.order.deliveryDate != null ? AppColors.darkCharcoal : Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Text(
            widget.order.deliveryAddress,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.darkCharcoal),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          ...widget.order.items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text('${item.quantity}x ', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.saffron, fontWeight: FontWeight.w900)),
                Expanded(child: Text(item.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600))),
                Text('₹${item.unitPrice * item.quantity}', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          )),
          const SizedBox(height: 16),
          _PriceLine(
            label: 'Items Total', 
            amount: widget.order.items.fold(0.0, (sum, i) => sum + (i.unitPrice * i.quantity))
          ),
          _PriceLine(label: 'Delivery Fee', amount: widget.order.deliveryFee),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Colors.black12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Earning', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w900, color: AppColors.darkCharcoal)),
                Text(
                  '₹${widget.order.items.fold(0.0, (sum, i) => sum + (i.unitPrice * i.quantity)) + widget.order.deliveryFee}', 
                  style: AppTextStyles.title.copyWith(fontSize: 22, color: AppColors.saffron, fontWeight: FontWeight.w900)
                ),
            ],
          ),
          if (widget.order.status.toLowerCase() == 'pending') ...[
            const SizedBox(height: 20),
            if (widget.isUnassigned)
              PrimaryButton(
                label: 'Claim Order',
                loading: _isUpdating,
                onTap: () => _updateStatus('accepted'),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isUpdating ? null : () => _showRejectDialog(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Reject Order',
                        style: AppTextStyles.button.copyWith(color: Colors.red, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Accept Order',
                      loading: _isUpdating,
                      onTap: () => _updateStatus('accepted'),
                    ),
                  ),
                ],
              ),
          ] else if (widget.order.status == 'accepted') ...[
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Mark as Out for Delivery',
              loading: _isUpdating,
              onTap: () => _updateStatus('out_for_delivery'),
            ),
          ] else if (widget.order.status == 'out_for_delivery') ...[
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Mark as Delivered',
              loading: _isUpdating,
              onTap: () => _updateStatus('delivered'),
            ),
          ],
        ],
      ),
    ),
  );
}
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        label = 'NEW';
        break;
      case 'accepted':
        color = Colors.indigo;
        label = 'ACCEPTED';
        break;
      case 'out_for_delivery':
        color = Colors.blue;
        label = 'OUT FOR DELIVERY';
        break;
      case 'delivered':
        color = Colors.green;
        label = 'DELIVERED';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'REJECTED';
        break;
      default:
        color = AppColors.softGrey;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.w800, fontSize: 10),
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label;
  final double amount;
  const _PriceLine({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.softGrey, fontWeight: FontWeight.w700)),
          Text('₹$amount', style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkCharcoal, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _StatusToggle extends ConsumerWidget {
  const _StatusToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(vendorActiveStatusProvider);

    return statusAsync.when(
      data: (isActive) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
          border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
        ),
        child: Row(
          children: [
            Icon(
              isActive ? Icons.online_prediction : Icons.do_not_disturb_on,
              color: isActive ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isActive ? 'LIVE & ACCEPTING ORDERS' : 'OFFLINE - SHOP CLOSED',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    isActive ? 'Your shop is visible to nearby customers.' : 'Customers cannot find your shop right now.',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 10, color: AppColors.softGrey),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: isActive,
                onChanged: (value) async {
                  await ref.read(samagriVendorRepositoryProvider).updateVendorActiveStatus(value);
                  ref.invalidate(vendorActiveStatusProvider);
                },
                activeColor: Colors.green,
                activeTrackColor: Colors.green.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox(height: 50, child: Center(child: LinearProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
