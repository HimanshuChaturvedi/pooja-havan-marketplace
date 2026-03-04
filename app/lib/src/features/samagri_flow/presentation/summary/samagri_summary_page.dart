import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/features/samagri_flow/application/samagri_session.dart';
import 'package:app/src/features/booking/application/booking_session.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';

class SamagriSummaryPage extends StatefulWidget {
  const SamagriSummaryPage({super.key});

  @override
  State<SamagriSummaryPage> createState() => _SamagriSummaryPageState();
}

class _SamagriSummaryPageState extends State<SamagriSummaryPage> {
  late List<SamagriItem> _items;
  bool _initialized = false;
  final bool _isBookingFlow = BookingSession.current != null;

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
    }
  }

  int get _itemsTotal => _items.fold(0, (sum, i) => sum + i.lineTotal);
  static const int _deliveryFee = 50;
  static const int _platformFee = 20;
  int get _finalTotal => _itemsTotal + _deliveryFee + _platformFee;

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
    SamagriSession.createFromCart(
      items: _items,
      isPartOfBooking: _isBookingFlow,
    );
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
                          // Item name
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
                          // Quantity controls
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
                          // Line total
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
                  _priceLine('Delivery Fee', _deliveryFee),
                  _priceLine('Platform Fee', _platformFee),
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
                        '₹$_finalTotal',
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
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: PrimaryButton(
          label: 'Confirm Order • ₹$_finalTotal',
          onTap: () {
            _syncSession();
            if (_isBookingFlow) {
              context.go('/home-summary');
            } else {
              context.push('/payment');
            }
          },
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
