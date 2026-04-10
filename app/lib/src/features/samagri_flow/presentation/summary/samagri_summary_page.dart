import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/features/samagri_flow/state/samagri_session_notifier.dart';
import 'package:app/src/features/booking/state/booking_session_notifier.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';
import 'package:app/src/features/samagri_flow/application/samagri_session.dart';
import '../../data/samagri_repository_provider.dart';
import 'package:app/src/features/home_booking/presentation/address/home_address_page.dart';
import 'package:app/src/features/booking/data/booking_providers.dart';
import 'package:app/src/features/auth/presentation/state/auth_provider_impl.dart';

class SamagriSummaryPage extends ConsumerStatefulWidget {
  const SamagriSummaryPage({super.key});

  @override
  ConsumerState<SamagriSummaryPage> createState() => _SamagriSummaryPageState();
}

class _SamagriSummaryPageState extends ConsumerState<SamagriSummaryPage> {
  late List<SamagriItem> _items;
  bool _initialized = false;
  bool _isBookingFlow = false;
  bool _isSubmitting = false;
  bool _isMatched = false; // 🚀 v2: START FALSE to force location check
  bool _isCheckingServiceability = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final samagri = ref.read(samagriSessionProvider);
      if (samagri.sessionId != null) {
        _isBookingFlow = samagri.isPartOfBooking; // ✅ SYNC FLOW TYPE
        _items = samagri.items.map((i) => SamagriItem(
          itemId: i.itemId,
          name: i.name,
          unitPrice: i.unitPrice,
          quantity: i.quantity,
        )).toList();
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final session = ref.read(samagriSessionProvider);
          _checkServiceability(session.latitude, session.longitude);
        });
      } else {
        _items = [];
      }
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncSession(); // 🚀 ENSURE PRICING IS SYNCED ON LOAD
      });
    }
  }

  int get _itemsTotal => _items.fold(0, (sum, i) => sum + i.lineTotal);

  void _incrementItem(int index) {
    setState(() {
      final item = _items[index];
      _items[index] = SamagriItem(
        itemId: item.itemId,
        name: item.name,
        unitPrice: item.unitPrice,
        quantity: item.quantity + 1,
      );
    });
    _syncSession();
  }

  void _decrementItem(int index) {
    setState(() {
      final item = _items[index];
      if (item.quantity <= 1) {
        _items.removeAt(index);
      } else {
        _items[index] = SamagriItem(
          itemId: item.itemId,
          name: item.name,
          unitPrice: item.unitPrice,
          quantity: item.quantity - 1,
        );
      }
    });
    _syncSession();
  }

  void _syncSession() {
    // ✅ Use Riverpod to update samagri draft
    ref.read(samagriSessionProvider.notifier).updateSamagriDraft(
          items: _items,
          isPartOfBooking: _isBookingFlow,
        );

    final deliveryFee = (_isBookingFlow && _items.isNotEmpty) || !_isBookingFlow ? 50.0 : 0.0;
    const platformFee = 20.0;

    if (_isBookingFlow) {
      final current = ref.read(bookingSessionProvider).current;
      if (current != null) {
        final updated = current.copyWith(samagriRequired: _items.isNotEmpty);
        ref.read(bookingSessionProvider.notifier).updateBookingDraft(updated);
      }
    }

    ref.read(bookingSessionProvider.notifier).updatePricing(
          samagriTotal: _itemsTotal.toDouble(),
          deliveryFee: deliveryFee,
          platformFee: platformFee,
        );
  }

  Future<void> _handleConfirm() async {
    if (_isSubmitting) return;

    // 🚀 JUST-IN-TIME AUTH GUARD
    final isAuthed = ref.read(isAuthenticatedProvider);
    if (!isAuthed) {
      debugPrint('🚨 SAMAGRI AUTH GUARD: Redirecting to Login.');
      // 🚀 v5.3: Use correct redirect based on flow to avoid "double-click" bug
      final target = _isBookingFlow ? '/home-summary' : '/samagri-summary';
      context.push('/login?redirectTo=$target');
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      // ✅ Read address from Riverpod state BEFORE sync
      final currentBooking = ref.read(bookingSessionProvider).current;
      final currentSamagri = ref.read(samagriSessionProvider);
      
      final deliveryAddr = _isBookingFlow
          ? currentBooking?.address
          : currentSamagri.addressText;

      final deliveryLat = _isBookingFlow
          ? currentBooking?.latitude
          : currentSamagri.latitude;

      final deliveryLon = _isBookingFlow
          ? currentBooking?.longitude
          : currentSamagri.longitude;

      _syncSession();
      
      // 🚀 FINAL SAFETY CHECK
      if (!_isMatched && !_isBookingFlow) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sorry, we do not deliver to this location yet.')),
          );
        }
        return;
      }
      
      final bookingState = ref.read(bookingSessionProvider);
 
      if (!_isBookingFlow) {
        // 🚀 ONLY create a standalone order if NOT in a Pooja flow.
        // Linked orders are handled by BookingRepository.createBooking().
        await ref.read(samagriRepositoryProvider).createOrder(
          items: _items,
          totalAmount: _itemsTotal.toDouble() + currentSamagri.deliveryFee + currentSamagri.platformFee,
          bookingId: null,
          deliveryAddress: deliveryAddr,
          latitude: deliveryLat,
          longitude: deliveryLon,
          deliveryFee: currentSamagri.deliveryFee.toDouble(),
          platformFee: currentSamagri.platformFee.toDouble(),
        );
      }
      
      if (mounted) {
        // 🚀 REFRESH HISTORY
        ref.invalidate(bookingsProvider);
        
        if (_isBookingFlow) {
          context.push('/home-summary');
        } else {
          // 🚀 SUCCESS REDIRECT: Go to dedicated success page
          context.push('/samagri-success'); 
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating order: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _checkServiceability(double? lat, double? lon) async {
    setState(() => _isCheckingServiceability = true);
    try {
      final vendorId = await ref.read(samagriRepositoryProvider).findNearestVendor(lat, lon);
      if (mounted) {
        setState(() {
          _isMatched = vendorId != null;
          _isCheckingServiceability = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isCheckingServiceability = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return AppScaffold(
        title: 'Order Summary',
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_basket_outlined, color: AppColors.softGrey.withOpacity(0.3), size: 64),
              const SizedBox(height: 16),
              Text(
                'No items in order',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.softGrey),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Go Back',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.saffron,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bookingState = ref.watch(bookingSessionProvider);
    final samagriState = ref.watch(samagriSessionProvider);
    
    final int localTotal = _itemsTotal.toInt() + 
        (_isBookingFlow 
            ? (bookingState.deliveryFee.toInt() + bookingState.platformFee.toInt()) 
            : (samagriState.deliveryFee.toInt() + samagriState.platformFee.toInt()));

    return AppScaffold(
      title: 'Order Summary',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            PrimaryCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review Items',
                    style: AppTextStyles.title.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_items.length, (index) {
                    final item = _items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.darkCharcoal,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹${item.unitPrice} each',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.softGrey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _QtyButton(
                                icon: Icons.remove,
                                onTap: () => _decrementItem(index),
                              ),
                              SizedBox(
                                width: 28,
                                child: Text(
                                  '${item.quantity}',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.darkCharcoal,
                                  ),
                                ),
                              ),
                              _QtyButton(
                                icon: Icons.add,
                                onTap: () => _incrementItem(index),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 56,
                            child: Text(
                              '₹${item.lineTotal}',
                              textAlign: TextAlign.right,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.darkCharcoal,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 32, color: Colors.black12),
                  _priceLine('Items Total', _itemsTotal),
                  _priceLine('Delivery Fee', bookingState.deliveryFee.toInt()),
                  _priceLine('Platform Fee', bookingState.platformFee.toInt()),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: AppTextStyles.title.copyWith(
                          fontSize: 20,
                          color: AppColors.darkCharcoal,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '₹$localTotal',
                        style: AppTextStyles.title.copyWith(
                          fontSize: 24,
                          color: AppColors.saffron,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!_isBookingFlow) ...[
              const SizedBox(height: 16),
              PrimaryCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delivery Address',
                          style: AppTextStyles.title.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                             Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => HomeAddressPage(
                                    city: 'Ghaziabad', 
                                    onAddressSaved: (address) {
                                      ref.read(samagriSessionProvider.notifier).attachAddress(
                                        '${address.line1}, ${address.city}',
                                        addressId: address.id,
                                        latitude: address.latitude,
                                        longitude: address.longitude,
                                      );
                                      if (address.latitude != null) {
                                        _checkServiceability(address.latitude!, address.longitude!);
                                      }
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              );
                          },
                          child: Text(
                          samagriState.addressText != null ? 'Change' : 'Select',
                            style: AppTextStyles.button.copyWith(color: AppColors.saffron),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (samagriState.addressText != null)
                      Text(
                        samagriState.addressText!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.darkCharcoal,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Text(
                        'Please select a delivery address to continue.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    
                    if (!_isMatched && !_isCheckingServiceability && samagriState.addressText != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Sorry, no Samagri vendors deliver within 3km of this location.',
                                style: AppTextStyles.bodySmall.copyWith(color: Colors.red, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: PrimaryButton(
          label: _isCheckingServiceability 
              ? 'Checking Delivery Area...'
              : (ref.watch(isAuthenticatedProvider)) 
                  ? (_isBookingFlow 
                      ? (!_isMatched ? 'Proceed w/o Samagri' : 'Next: Review Pooja')
                      : 'Confirm Order • ₹$localTotal')
                  : 'Sign In to Order • ₹$localTotal',
          onTap: (_isSubmitting || _isCheckingServiceability) 
              ? null
              : (!ref.watch(isAuthenticatedProvider))
                  ? _handleConfirm 
                  : (_isBookingFlow)
                      ? _handleConfirm // Always allow proceeding to Pooja
                      : (_isMatched && samagriState.addressText != null)
                          ? _handleConfirm
                          : null,
          loading: _isSubmitting,
        ),
      ),
    );
  }

  Widget _priceLine(String label, int amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.softGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '₹$amount',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.darkCharcoal,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.saffron.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.saffron, size: 16),
      ),
    );
  }
}
