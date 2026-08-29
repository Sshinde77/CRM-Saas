import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../providers/api_provider.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';

class QuotationDetailScreen extends StatefulWidget {
  final String quotationId;

  const QuotationDetailScreen({super.key, required this.quotationId});

  @override
  State<QuotationDetailScreen> createState() => _QuotationDetailScreenState();
}

class _QuotationDetailScreenState extends State<QuotationDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late ApiProvider _apiProvider;
  bool _providerReady = false;
  bool _isLoading = true;
  bool _isActionLoading = false;
  String? _errorMessage;
  _QuotationDetail? _quotation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providerReady) return;
    _apiProvider = ApiProviderScope.of(context);
    _providerReady = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadQuotation();
    });
  }

  Future<void> _loadQuotation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final json = await _apiProvider.fetchQuotationById(widget.quotationId);
      if (!mounted) return;
      setState(() {
        _quotation = _QuotationDetail.fromJson(json);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _runAction(Future<void> Function() action) async {
    if (_isActionLoading) return;
    setState(() => _isActionLoading = true);
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      _showSnack(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isActionLoading = false);
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _downloadPdf() async {
    await _runAction(() async {
      final bytes = await _apiProvider.downloadQuotationPdf(widget.quotationId);
      if (!mounted) return;
      _showSnack('PDF downloaded from API (${bytes.length} bytes).');
    });
  }

  Future<void> _updateStatus(String status) async {
    await _runAction(() async {
      final json = await _apiProvider.updateQuotationStatus(
        quotationId: widget.quotationId,
        status: status,
      );
      if (!mounted) return;
      setState(() => _quotation = _QuotationDetail.fromJson(json));
      _showSnack('Quotation marked as ${_titleCase(status)}.');
    });
  }

  Future<void> _deleteQuotation() async {
    final quotation = _quotation;
    if (quotation == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Delete Quotation',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Delete ${quotation.number}? This action cannot be undone.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await _runAction(() async {
      await _apiProvider.deleteQuotation(widget.quotationId);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    });
  }

  Future<void> _openConvertDialog() async {
    await _runAction(() async {
      final warehouses = await _apiProvider.fetchWarehouses();
      if (!mounted) return;

      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => _ConvertQuotationDialog(warehouses: warehouses),
      );
      if (result == null) return;

      await _apiProvider.convertQuotationToOrder(
        quotationId: widget.quotationId,
        request: result,
      );
      final json = await _apiProvider.fetchQuotationById(widget.quotationId);
      if (!mounted) return;
      setState(() => _quotation = _QuotationDetail.fromJson(json));
      _showSnack('Quotation converted to order.');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeItem: 'Quotation'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Quotation Detail',
              leadingIcon: Icons.arrow_back_rounded,
              onLeadingTap: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadQuotation,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _ErrorPanel(message: _errorMessage!, onRetry: _loadQuotation),
        ],
      );
    }

    final quotation = _quotation;
    if (quotation == null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _ErrorPanel(message: 'Quotation not found.', onRetry: _loadQuotation),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 920;

        return ListView(
          padding: EdgeInsets.fromLTRB(
            compact ? 14 : 22,
            14,
            compact ? 14 : 22,
            24,
          ),
          children: [
            _HeroPanel(
              quotation: quotation,
              isActionLoading: _isActionLoading,
              onDownloadPdf: _downloadPdf,
              onMarkSent: () => _updateStatus('sent'),
              onReject: () => _updateStatus('rejected'),
              onAccept: () => _updateStatus('accepted'),
              onConvert: _openConvertDialog,
              onDelete: _deleteQuotation,
            ),
            const SizedBox(height: 16),
            _StatsGrid(quotation: quotation),
            const SizedBox(height: 16),
            _ItemsSection(items: quotation.items, compact: compact),
            const SizedBox(height: 16),
            if (compact)
              Column(
                children: [
                  _CustomerDeliveryCard(quotation: quotation),
                  const SizedBox(height: 16),
                  _QuotationInfoCard(quotation: quotation),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _CustomerDeliveryCard(quotation: quotation)),
                  const SizedBox(width: 16),
                  Expanded(child: _QuotationInfoCard(quotation: quotation)),
                ],
              ),
            if (quotation.notes.isNotEmpty ||
                quotation.termsConditions.isNotEmpty) ...[
              const SizedBox(height: 16),
              _OptionalSections(quotation: quotation),
            ],
          ],
        );
      },
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final _QuotationDetail quotation;
  final bool isActionLoading;
  final VoidCallback onDownloadPdf;
  final VoidCallback onMarkSent;
  final VoidCallback onReject;
  final VoidCallback onAccept;
  final VoidCallback onConvert;
  final VoidCallback onDelete;

  const _HeroPanel({
    required this.quotation,
    required this.isActionLoading,
    required this.onDownloadPdf,
    required this.onMarkSent,
    required this.onReject,
    required this.onAccept,
    required this.onConvert,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final status = quotation.status.toLowerCase();
    final converted = status == 'converted';

    final actions = <Widget>[
      _ActionPill(
        icon: Icons.picture_as_pdf_outlined,
        label: 'Download PDF',
        onPressed: isActionLoading ? null : onDownloadPdf,
      ),
      if (status == 'draft')
        _ActionPill(
          icon: Icons.send_outlined,
          label: 'Mark as Sent',
          onPressed: isActionLoading ? null : onMarkSent,
        ),
      if (status == 'sent') ...[
        _ActionPill(
          icon: Icons.close_rounded,
          label: 'Reject',
          danger: true,
          onPressed: isActionLoading ? null : onReject,
        ),
        _ActionPill(
          icon: Icons.check_circle_outline_rounded,
          label: 'Mark as Accepted',
          onPressed: isActionLoading ? null : onAccept,
        ),
      ],
      if (status == 'accepted')
        _ActionPill(
          icon: Icons.inventory_2_outlined,
          label: 'Convert to Order',
          onPressed: isActionLoading ? null : onConvert,
        ),
      if (!converted)
        _ActionPill(
          icon: Icons.delete_outline_rounded,
          label: 'Delete',
          danger: true,
          onPressed: isActionLoading ? null : onDelete,
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF082F0A), Color(0xFF0B4A06), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B4A06).withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: const Icon(
                  Icons.request_quote_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          quotation.number,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        _StatusChip(
                          label: _titleCase(quotation.status),
                          foreground: quotation.statusColor,
                          background: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      quotation.customerName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.86),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(spacing: 10, runSpacing: 10, children: actions),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final _QuotationDetail quotation;

  const _StatsGrid({required this.quotation});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cardWidth = width < 680 ? width : (width - 36) / 4;
        final stats = [
          _StatData(
            'Subtotal',
            _formatMoney(quotation.subtotal),
            Icons.summarize_outlined,
          ),
          _StatData(
            'Tax',
            _formatMoney(quotation.taxTotal),
            Icons.percent_rounded,
          ),
          _StatData(
            'Total',
            _formatMoney(quotation.total),
            Icons.payments_outlined,
          ),
          _StatData(
            'Items',
            quotation.items.length.toString(),
            Icons.inventory_2_outlined,
          ),
        ];

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final stat in stats)
              SizedBox(
                width: cardWidth,
                child: _StatCard(stat: stat),
              ),
          ],
        );
      },
    );
  }
}

class _ItemsSection extends StatelessWidget {
  final List<_QuotationItem> items;
  final bool compact;

  const _ItemsSection({required this.items, required this.compact});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Quotation Items',
      icon: Icons.list_alt_rounded,
      child: items.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'No quotation items found.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : compact
          ? Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  _ItemMobileCard(item: items[i]),
                  if (i != items.length - 1) const SizedBox(height: 10),
                ],
              ],
            )
          : _ItemsTable(items: items),
    );
  }
}

class _ItemsTable extends StatelessWidget {
  final List<_QuotationItem> items;

  const _ItemsTable({required this.items});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 900),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 3, child: _TableHeader('Product')),
                  Expanded(child: _TableHeader('Qty')),
                  Expanded(child: _TableHeader('UOM')),
                  Expanded(child: _TableHeader('Unit Price')),
                  Expanded(child: _TableHeader('Discount')),
                  Expanded(child: _TableHeader('Tax')),
                  Expanded(child: _TableHeader('Line Total')),
                ],
              ),
            ),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        item.productName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Expanded(child: _TableValue(item.quantityText)),
                    Expanded(child: _TableValue(item.uom)),
                    Expanded(child: _TableValue(_formatMoney(item.unitPrice))),
                    Expanded(child: _TableValue('${item.discountText}%')),
                    Expanded(child: _TableValue('${item.taxRateText}%')),
                    Expanded(child: _TableValue(_formatMoney(item.lineTotal))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomerDeliveryCard extends StatelessWidget {
  final _QuotationDetail quotation;

  const _CustomerDeliveryCard({required this.quotation});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Customer & Delivery',
      icon: Icons.local_shipping_outlined,
      child: Column(
        children: [
          _DetailRow('Customer', quotation.customerName),
          _DetailRow('Billing Address', quotation.billingAddress),
          _DetailRow('Shipping Address', quotation.shippingAddress),
        ],
      ),
    );
  }
}

class _QuotationInfoCard extends StatelessWidget {
  final _QuotationDetail quotation;

  const _QuotationInfoCard({required this.quotation});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Quotation Information',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          _DetailRow('Quotation Date', _formatDate(quotation.quotationDate)),
          _DetailRow('Valid Until', _formatDate(quotation.validUntil)),
          _DetailRow('Salesperson', quotation.salespersonName),
          _DetailRow('Currency', quotation.currency),
          _DetailRow('Payment Terms', quotation.paymentTerms),
          _DetailRow('Delivery Terms', quotation.deliveryTerms),
        ],
      ),
    );
  }
}

class _OptionalSections extends StatelessWidget {
  final _QuotationDetail quotation;

  const _OptionalSections({required this.quotation});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (quotation.notes.isNotEmpty)
          _SectionCard(
            title: 'Notes',
            icon: Icons.notes_rounded,
            child: _LongText(quotation.notes),
          ),
        if (quotation.notes.isNotEmpty && quotation.termsConditions.isNotEmpty)
          const SizedBox(height: 16),
        if (quotation.termsConditions.isNotEmpty)
          _SectionCard(
            title: 'Terms & Conditions',
            icon: Icons.gavel_outlined,
            child: _LongText(quotation.termsConditions),
          ),
      ],
    );
  }
}

class _ConvertQuotationDialog extends StatefulWidget {
  final List<Map<String, dynamic>> warehouses;

  const _ConvertQuotationDialog({required this.warehouses});

  @override
  State<_ConvertQuotationDialog> createState() =>
      _ConvertQuotationDialogState();
}

class _ConvertQuotationDialogState extends State<_ConvertQuotationDialog> {
  String? _warehouseId;
  DateTime? _deliveryDate;
  String _fulfilmentMethod = 'standard';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: const Text(
        'Convert to Order',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _warehouseId,
              decoration: _dialogInputDecoration('Warehouse'),
              items: widget.warehouses.map((warehouse) {
                final id = _jsonText(warehouse, const ['id', 'warehouse_id']);
                final name = _jsonText(warehouse, const [
                  'name',
                  'warehouse_name',
                ], fallback: id);
                return DropdownMenuItem(value: id, child: Text(name));
              }).toList(),
              onChanged: (value) => setState(() => _warehouseId = value),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => _deliveryDate = picked);
                }
              },
              child: InputDecorator(
                decoration: _dialogInputDecoration('Delivery Date'),
                child: Text(
                  _deliveryDate == null
                      ? 'Select delivery date'
                      : _formatDate(_deliveryDate),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _fulfilmentMethod,
              decoration: _dialogInputDecoration('Fulfilment Method'),
              items: const [
                DropdownMenuItem(value: 'standard', child: Text('Standard')),
                DropdownMenuItem(value: 'pickup', child: Text('Pickup')),
                DropdownMenuItem(value: 'express', child: Text('Express')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _fulfilmentMethod = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            final payload = <String, dynamic>{
              if ((_warehouseId ?? '').trim().isNotEmpty)
                'warehouse_id': _warehouseId,
              if (_deliveryDate != null)
                'delivery_date': DateTime.utc(
                  _deliveryDate!.year,
                  _deliveryDate!.month,
                  _deliveryDate!.day,
                ).toIso8601String(),
              'fulfilment_method': _fulfilmentMethod,
            };
            Navigator.of(context).pop(payload);
          },
          child: const Text('Convert'),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final _StatData stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(stat.icon, color: AppColors.primary, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;
  final VoidCallback? onPressed;

  const _ActionPill({
    required this.icon,
    required this.label,
    this.danger = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.red : AppColors.primary;
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: color,
        disabledBackgroundColor: Colors.white.withValues(alpha: 0.55),
        disabledForegroundColor: color.withValues(alpha: 0.45),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;

  const _StatusChip({
    required this.label,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LongText extends StatelessWidget {
  final String value;

  const _LongText(this.value);

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        height: 1.45,
      ),
    );
  }
}

class _ItemMobileCard extends StatelessWidget {
  final _QuotationItem item;

  const _ItemMobileCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.productName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          _DetailRow('Qty / UOM', '${item.quantityText} ${item.uom}'),
          _DetailRow('Unit Price', _formatMoney(item.unitPrice)),
          _DetailRow(
            'Discount / Tax',
            '${item.discountText}% / ${item.taxRateText}%',
          ),
          _DetailRow('Line Total', _formatMoney(item.lineTotal)),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String label;

  const _TableHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _TableValue extends StatelessWidget {
  final String value;

  const _TableValue(this.value);

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorPanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: AppColors.textSecondary,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _QuotationDetail {
  final String id;
  final String number;
  final String status;
  final String customerName;
  final String billingAddress;
  final String shippingAddress;
  final DateTime? quotationDate;
  final DateTime? validUntil;
  final String salespersonName;
  final String currency;
  final String paymentTerms;
  final String deliveryTerms;
  final String notes;
  final String termsConditions;
  final List<_QuotationItem> items;
  final double subtotal;
  final double taxTotal;
  final double total;

  const _QuotationDetail({
    required this.id,
    required this.number,
    required this.status,
    required this.customerName,
    required this.billingAddress,
    required this.shippingAddress,
    required this.quotationDate,
    required this.validUntil,
    required this.salespersonName,
    required this.currency,
    required this.paymentTerms,
    required this.deliveryTerms,
    required this.notes,
    required this.termsConditions,
    required this.items,
    required this.subtotal,
    required this.taxTotal,
    required this.total,
  });

  factory _QuotationDetail.fromJson(Map<String, dynamic> json) {
    final data = _unwrapMap(json);
    final rawItems = _jsonList(data, const ['items', 'quotation_items']);
    final items = rawItems.map(_QuotationItem.fromJson).toList();
    final calculatedSubtotal = items.fold<double>(
      0,
      (sum, item) => sum + item.subtotalAfterDiscount,
    );
    final calculatedTax = items.fold<double>(
      0,
      (sum, item) => sum + item.taxAmount,
    );
    final calculatedTotal = items.fold<double>(
      0,
      (sum, item) => sum + item.lineTotal,
    );

    return _QuotationDetail(
      id: _jsonText(data, const ['id', 'quotation_id']),
      number: _jsonText(data, const [
        'quotation_number',
        'quotationNumber',
        'number',
      ], fallback: '-'),
      status: _jsonText(data, const ['status'], fallback: 'draft'),
      customerName: _jsonText(
        data,
        const ['customer_name', 'customerName'],
        nestedKeys: const ['customer'],
      ),
      billingAddress: _jsonText(data, const [
        'billing_address',
        'billingAddress',
      ], fallback: '-'),
      shippingAddress: _jsonText(data, const [
        'shipping_address',
        'shippingAddress',
      ], fallback: '-'),
      quotationDate: _jsonDate(data, const [
        'quotation_date',
        'quotationDate',
        'date',
      ]),
      validUntil: _jsonDate(data, const ['valid_until', 'validUntil']),
      salespersonName: _jsonText(
        data,
        const ['salesperson_name', 'salespersonName'],
        nestedKeys: const ['salesperson', 'user'],
      ),
      currency: _jsonText(data, const ['currency'], fallback: 'INR'),
      paymentTerms: _jsonText(data, const [
        'payment_terms',
        'paymentTerms',
      ], fallback: '-'),
      deliveryTerms: _jsonText(data, const [
        'delivery_terms',
        'deliveryTerms',
      ], fallback: '-'),
      notes: _jsonText(data, const ['notes'], fallback: ''),
      termsConditions: _jsonText(data, const [
        'terms_conditions',
        'termsConditions',
      ], fallback: ''),
      items: items,
      subtotal: _jsonNumber(data, const [
        'subtotal',
        'sub_total',
        'taxable_amount',
      ], fallback: calculatedSubtotal),
      taxTotal: _jsonNumber(data, const [
        'tax',
        'tax_total',
        'taxTotal',
        'total_tax',
      ], fallback: calculatedTax),
      total: _jsonNumber(data, const [
        'total',
        'grand_total',
        'amount',
        'total_amount',
      ], fallback: calculatedTotal),
    );
  }

  Color get statusColor => _statusColor(status);
}

class _QuotationItem {
  final String productName;
  final double quantity;
  final String uom;
  final double unitPrice;
  final double discount;
  final double taxRate;
  final double lineTotal;

  const _QuotationItem({
    required this.productName,
    required this.quantity,
    required this.uom,
    required this.unitPrice,
    required this.discount,
    required this.taxRate,
    required this.lineTotal,
  });

  factory _QuotationItem.fromJson(Map<String, dynamic> json) {
    final quantity = _jsonNumber(json, const ['quantity', 'qty']);
    final unitPrice = _jsonNumber(json, const [
      'unit_price',
      'unitPrice',
      'price',
    ]);
    final discount = _jsonNumber(json, const ['discount', 'discount_percent']);
    final taxRate = _jsonNumber(json, const ['tax_rate', 'taxRate', 'tax']);
    final subtotal = quantity * unitPrice;
    final discounted = subtotal - (subtotal * discount / 100);
    final taxAmount = discounted * taxRate / 100;

    return _QuotationItem(
      productName: _jsonText(
        json,
        const ['product_name', 'productName', 'name'],
        nestedKeys: const ['product'],
      ),
      quantity: quantity,
      uom: _jsonText(json, const ['uom', 'unit'], fallback: '-'),
      unitPrice: unitPrice,
      discount: discount,
      taxRate: taxRate,
      lineTotal: _jsonNumber(json, const [
        'line_total',
        'lineTotal',
        'total',
      ], fallback: discounted + taxAmount),
    );
  }

  double get subtotalAfterDiscount {
    final subtotal = quantity * unitPrice;
    return subtotal - (subtotal * discount / 100);
  }

  double get taxAmount => subtotalAfterDiscount * taxRate / 100;

  String get quantityText => _numberText(quantity);
  String get discountText => _numberText(discount);
  String get taxRateText => _numberText(taxRate);
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;

  const _StatData(this.label, this.value, this.icon);
}

Map<String, dynamic> _unwrapMap(Map<String, dynamic> json) {
  for (final key in const ['quotation', 'data', 'result']) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
  }
  return json;
}

String _jsonText(
  Map<String, dynamic> json,
  List<String> keys, {
  List<String> nestedKeys = const [],
  String fallback = '-',
}) {
  for (final key in keys) {
    final value = json[key];
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) return text;
  }

  for (final nestedKey in nestedKeys) {
    final nested = json[nestedKey];
    if (nested is Map<String, dynamic>) {
      final value = _jsonText(nested, const [
        'name',
        'full_name',
        'customer_name',
        'product_name',
      ], fallback: '');
      if (value.isNotEmpty) return value;
    }
  }

  return fallback;
}

double _jsonNumber(
  Map<String, dynamic> json,
  List<String> keys, {
  double fallback = 0,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value != null) {
      final sanitized = value.toString().replaceAll(RegExp(r'[^0-9.\-]'), '');
      final parsed = double.tryParse(sanitized);
      if (parsed != null) return parsed;
    }
  }
  return fallback;
}

List<Map<String, dynamic>> _jsonList(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) return value.whereType<Map<String, dynamic>>().toList();
  }
  return const [];
}

DateTime? _jsonDate(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key]?.toString().trim();
    if (value == null || value.isEmpty) continue;
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed.toLocal();
  }
  return null;
}

InputDecoration _dialogInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: AppColors.background,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: AppColors.borderLight),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: AppColors.borderLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
  );
}

Color _statusColor(String status) {
  return switch (status.toLowerCase()) {
    'sent' => const Color(0xFF2563EB),
    'accepted' => const Color(0xFF16A34A),
    'rejected' => const Color(0xFFDC2626),
    'converted' => const Color(0xFF7C3AED),
    _ => const Color(0xFF6B7280),
  };
}

String _titleCase(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return '-';
  return normalized
      .split(RegExp(r'[_\s-]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
      .join(' ');
}

String _formatDate(DateTime? date) {
  if (date == null) return '-';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}

String _formatMoney(double value) {
  final sign = value < 0 ? '-' : '';
  final amount = value.abs().toStringAsFixed(value % 1 == 0 ? 0 : 2);
  final parts = amount.split('.');
  final whole = parts.first;
  final fraction = parts.length > 1 ? '.${parts.last}' : '';
  final lastThree = whole.length > 3
      ? whole.substring(whole.length - 3)
      : whole;
  final leading = whole.length > 3 ? whole.substring(0, whole.length - 3) : '';
  final chunks = <String>[];
  var rest = leading;
  while (rest.length > 2) {
    chunks.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) chunks.insert(0, rest);
  final grouped = chunks.isEmpty ? lastThree : '${chunks.join(',')},$lastThree';
  return '$sign Rs. $grouped$fraction';
}

String _numberText(double value) {
  return value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
}
