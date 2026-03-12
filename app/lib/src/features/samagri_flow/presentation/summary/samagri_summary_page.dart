import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/features/samagri_flow/application/samagri_session.dart';
import 'package:app/src/features/booking/application/booking_session.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';
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
  final bool _isBookingFlow = BookingSession.current != null;
  bool _isSubmitting = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final samagri = SamagriSession.current;
      if (samagri != null) {
        _items = samagri.items.map((i) => SamagriItem(
          itemId: i.itemId,
          name: i.name,
          unitPrice: i.unitPrice,
          quantity: i.quantity,
        )).toList();
      } else {
        _items = [];
      }
      _initialized = true;
      _syncSession(); // 🚀 ENSURE PRICING IS SYNCED ON LOAD
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
    // ✅ PRESERVE ADDRESS before createFromCart wipes it
    final savedAddress = SamagriSession.current?.addressText;

    SamagriSession.createFromCart(
      items: _items,
      isPartOfBooking: _isBookingFlow,
    );

    // Re-attach address if it was set
    if (savedAddress != null) {
      SamagriSession.attachAddress(savedAddress);
    }
 
    if (_isBookingFlow) {
      if (_items.isNotEmpty) {
        BookingSession.current?.samagriRequired = true;
        BookingSession.deliveryFee = 50.0;
        BookingSession.platformFee = 20.0;
      } else {
        BookingSession.current?.samagriRequired = false;
        BookingSession.deliveryFee = 0.0;
        BookingSession.platformFee = 20.0;
      }
    } else {
      // 🚀 STANDALONE SYNC: Ensure fees show up in Payment Screen
      BookingSession.deliveryFee = 50.0;
      BookingSession.platformFee = 20.0;
    }
 
    BookingSession.samagriTotal = _itemsTotal.toDouble();
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
      // Read address BEFORE _syncSession (which recreates the session)
      final deliveryAddr = _isBookingFlow
          ? BookingSession.current?.address
          : SamagriSession.current?.addressText;

      _syncSession();
 
      if (!_isBookingFlow) {
        // 🚀 ONLY create a standalone order if NOT in a Pooja flow.
        // Linked orders are handled by BookingRepository.createBooking().
        await ref.read(samagriRepositoryProvider).createOrder(
          items: _items,
          totalAmount: BookingSession.totalAmount,
          bookingId: null,
          deliveryAddress: deliveryAddr,
        );
      }
      
      if (mounted) {
        // 🚀 REFRESH HISTORY
        ref.invalidate(bookingsProvider);
        
        if (_isBookingFlow) {
          context.go('/home-summary');
        } else {
          // 🚀 SUCCESS REDIRECT: Go to dedicated success page
          context.go('/samagri-success'); 
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
                  _priceLine('Delivery Fee', BookingSession.deliveryFee.toInt()),
                  _priceLine('Platform Fee', BookingSession.platformFee.toInt()),
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
                        '₹${BookingSession.totalAmount.toInt()}',
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
                                    onAddressSaved: (addr) {
                                      setState(() {
                                        SamagriSession.attachAddress(addr);
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              );
                          },
                          child: Text(
                            SamagriSession.current?.addressText != null ? 'Change' : 'Select',
                            style: AppTextStyles.button.copyWith(color: AppColors.saffron),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (SamagriSession.current?.addressText != null)
                      Text(
                        SamagriSession.current!.addressText!,
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
          label: (ref.watch(isAuthenticatedProvider)) 
              ? (_isBookingFlow 
                  ? 'Next: Review Pooja • ₹${BookingSession.totalAmount.toInt()}'
                  : 'Confirm Order • ₹${BookingSession.totalAmount.toInt()}')
              : 'Sign In to Order • ₹${BookingSession.totalAmount.toInt()}',
          onTap: (_isSubmitting || (!_isBookingFlow && SamagriSession.current?.addressText == null)) 
              ? null 
              : _handleConfirm,
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
