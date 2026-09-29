import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/app_user.dart';
import '../../utils/product_image_url.dart';
import 'voice_input_sheet.dart';

class DeliveryPartnerSearchDialog extends StatefulWidget {
  const DeliveryPartnerSearchDialog({
    super.key,
    required this.partners,
    this.selectedPartnerId,
  });

  final List<AppUser> partners;
  final String? selectedPartnerId;

  @override
  State<DeliveryPartnerSearchDialog> createState() =>
      _DeliveryPartnerSearchDialogState();
}

class _DeliveryPartnerSearchDialogState
    extends State<DeliveryPartnerSearchDialog> {
  static const _accent = AppColors.deliveryGreen;
  static const _heading = AppColors.primary;
  static const _muted = AppColors.textSecondary;
  static const _border = AppColors.border;

  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _voiceSearch() async {
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const VoiceInputSheet(),
    );
    if (!mounted || text == null) return;
    setState(() => _search.text = text.trim());
  }

  bool _matches(AppUser partner) {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return true;
    final fields = [
      partner.name,
      partner.displayName,
      partner.email,
      partner.phone,
      partner.employeeId,
      partner.designation,
      partner.id,
    ];
    if (fields.any((value) => value?.toLowerCase().contains(query) ?? false)) {
      return true;
    }
    final digits = query.replaceAll(RegExp(r'\D'), '');
    return digits.isNotEmpty &&
        RegExp(r'^[+\d\s()\-]+$').hasMatch(query) &&
        [partner.phone, partner.alternateMobileNumber].any(
          (phone) =>
              phone?.replaceAll(RegExp(r'\D'), '').contains(digits) ?? false,
        );
  }

  @override
  Widget build(BuildContext context) {
    final partners = widget.partners.where(_matches).toList();
    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 820,
          maxHeight: (MediaQuery.sizeOf(context).height * 0.85)
              .clamp(0.0, 780.0)
              .toDouble(),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.delivery_dining_outlined,
                    color: _heading,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Search Delivery Partner',
                      style: TextStyle(
                        color: _heading,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: _muted),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: _heading, fontSize: 13),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  hintText:
                      'Search by name, email, employee ID or phone number...',
                  hintStyle: const TextStyle(color: _muted, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: _muted),
                  suffixIcon: IconButton(
                    tooltip: 'Search by voice',
                    onPressed: _voiceSearch,
                    icon: const Icon(Icons.mic_none, color: _accent),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceSoft,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: _border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: _border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: _accent),
                  ),
                ),
              ),
            ),
            Flexible(
              child: partners.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        widget.partners.isEmpty
                            ? 'No delivery partners available.'
                            : 'No delivery partners found. Try another search.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: _muted),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      itemCount: partners.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, index) =>
                          _partnerCard(partners[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _partnerCard(AppUser partner) {
    final selected = partner.id == widget.selectedPartnerId;
    return Material(
      color: selected ? AppColors.deliveryGreenSoft : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: selected ? _accent : _border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(partner),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 640;
            final phone = _detail(
              Icons.phone,
              partner.phone?.trim().isNotEmpty == true
                  ? partner.phone!
                  : 'No phone available',
              color: _accent,
            );
            return Padding(
              padding: EdgeInsets.all(wide ? 18 : 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PartnerAvatar(partner: partner, size: wide ? 80 : 46),
                  SizedBox(width: wide ? 18 : 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partner.name.trim().isEmpty
                              ? 'Delivery Partner'
                              : partner.name,
                          style: const TextStyle(
                            color: _heading,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _detail(
                          Icons.badge_outlined,
                          partner.employeeId?.trim().isNotEmpty == true
                              ? partner.employeeId!
                              : partner.id,
                        ),
                        _detail(
                          Icons.email_outlined,
                          partner.email.trim().isEmpty
                              ? 'No email available'
                              : partner.email,
                        ),
                        if (!wide) phone,
                      ],
                    ),
                  ),
                  if (wide)
                    Container(
                      width: 220,
                      constraints: const BoxConstraints(minHeight: 80),
                      margin: const EdgeInsets.only(left: 20),
                      padding: const EdgeInsets.only(left: 20),
                      decoration: const BoxDecoration(
                        border: Border(left: BorderSide(color: _border)),
                      ),
                      alignment: Alignment.centerLeft,
                      child: phone,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _detail(IconData icon, String value, {Color color = _muted}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: _muted, fontSize: 13),
              ),
            ),
          ],
        ),
      );
}

class _PartnerAvatar extends StatelessWidget {
  const _PartnerAvatar({required this.partner, required this.size});

  final AppUser partner;
  final double size;

  String get _initials {
    final name = partner.name.trim();
    final parts = name.split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    final initials = parts.take(2).map((part) => part[0].toUpperCase()).join();
    return initials.isEmpty ? 'DP' : initials;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = normalizeProductImageUrl(partner.profilePhoto);
    final fallback = Container(
      color: AppColors.deliveryGreenSoft,
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          color: _DeliveryPartnerSearchDialogState._accent,
          fontSize: size >= 64 ? 22 : 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl == null
            ? fallback
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stackTrace) => fallback,
              ),
      ),
    );
  }
}
