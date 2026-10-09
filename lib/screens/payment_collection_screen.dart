import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/app_colors.dart';
import '../models/customer_model.dart';
import '../providers/api_provider.dart';
import '../widgets/delivery/delivery_top_bar.dart';
import '../widgets/delivery/customer_search_dialog.dart';
import 'delivery/customers/create_delivery_customer_screen.dart';
import 'shared/map_location_view_screen.dart';

class PaymentCollectionScreen extends StatefulWidget {
  const PaymentCollectionScreen({
    super.key,
    this.initialCustomerId,
  });

  final String? initialCustomerId;

  @override
  State<PaymentCollectionScreen> createState() =>
      _PaymentCollectionScreenState();
}

class _PaymentCollectionScreenState extends State<PaymentCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  final _imagePicker = ImagePicker();

  List<CustomerModel> _customers = const [];
  _PaymentCustomer? _selectedCustomer;
  String _paymentMode = 'cash';
  bool _loadingCustomers = true;
  bool _loadingDetail = false;
  bool _submitting = false;
  bool _pickingProof = false;
  bool _didApplyInitialCustomer = false;
  Uint8List? _proofBytes;
  String? _proofName;
  String? _error;

  double get _amountCollected =>
      double.tryParse(_amountController.text.trim()) ?? 0;
  double get _amountDue => _selectedCustomer?.pendingAmount ?? 0;
  double get _remainingAmount =>
      (_amountDue - _amountCollected).clamp(0, double.infinity).toDouble();

  @override
  void initState() {
    super.initState();
    // The customer provider depends on inherited context and notifies listeners.
    // Wait until the first build finishes before starting the request.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadCustomers();
    });
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _loadingCustomers = true;
      _error = null;
    });
    try {
      final customers = await ApiProviderScope.of(context).fetchCustomers();
      if (!mounted) return;
      setState(() {
        _customers = customers;
        _loadingCustomers = false;
      });
      final initialCustomerId = widget.initialCustomerId?.trim();
      if (!_didApplyInitialCustomer &&
          initialCustomerId != null &&
          initialCustomerId.isNotEmpty) {
        _didApplyInitialCustomer = true;
        CustomerModel? initialCustomer;
        for (final customer in customers) {
          if (customer.id == initialCustomerId) {
            initialCustomer = customer;
            break;
          }
        }
        if (initialCustomer != null) {
          await _selectCustomer(_PaymentCustomer.fromModel(initialCustomer));
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingCustomers = false;
        _error = 'Could not load customers. Please try again.';
      });
    }
  }

  Future<void> _selectCustomer(_PaymentCustomer? customer) async {
    if (customer == null) return;
    setState(() {
      _selectedCustomer = customer;
      _loadingDetail = true;
      _amountController.clear();
    });
    try {
      final detail = await ApiProviderScope.of(
        context,
      ).fetchCustomerById(customer.id.toString());
      final next = _PaymentCustomer.fromModel(detail, fallback: customer);
      if (!mounted) return;
      setState(() {
        _selectedCustomer = next;
        _amountController.text = next.pendingAmount > 0
            ? _plainAmount(next.pendingAmount)
            : '';
        _loadingDetail = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingDetail = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load pending amount.')),
      );
    }
  }

  void _openCustomerMap() {
    final customer = _selectedCustomer;
    if (customer == null || !customer.hasLocation) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MapLocationViewScreen(
          latitude: customer.latitude!,
          longitude: customer.longitude!,
          title: customer.name,
          subtitle: customer.address,
        ),
      ),
    );
  }

  void _openCustomerModelMap(CustomerModel customer) {
    final latitude = customer.mapLatitude;
    final longitude = customer.mapLongitude;
    if (latitude == null || longitude == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MapLocationViewScreen(
          latitude: latitude,
          longitude: longitude,
          title: customer.businessName?.trim().isNotEmpty == true
              ? customer.businessName!
              : customer.name,
          subtitle: _customerAddress(customer),
        ),
      ),
    );
  }

  Future<void> _recordCollection() async {
    if (!_formKey.currentState!.validate() || _selectedCustomer == null) return;
    setState(() => _submitting = true);
    try {
      final provider = ApiProviderScope.of(context);
      String? paymentProofUrl;
      final proofBytes = _proofBytes;
      if (proofBytes != null) {
        final uploadedProof = await provider.uploadGenericFile(
          fileBytes: proofBytes,
          fileName: _proofName ?? 'payment-proof.jpg',
        );
        paymentProofUrl = uploadedProof.url ?? uploadedProof.fileId;
      }

      await provider.recordCustomerCollection(
        customerId: _selectedCustomer!.id.toString(),
        amount: _amountCollected,
        paymentMethod: _paymentMode,
        paymentDate: _apiDate(DateTime.now()),
        reference: _referenceController.text,
        notes: _notesController.text,
        paymentProofUrl: paymentProofUrl,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Collection recorded - awaiting reconciliation.'),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collection failed. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _choosePaymentProof() async {
    if (_pickingProof || _submitting) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Payment Proof',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.upload_file_outlined, size: 22),
                title: const Text('Upload file'),
                subtitle: const Text('Choose an image from your device'),
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, size: 22),
                title: const Text('Take photo'),
                subtitle: const Text('Capture using the camera'),
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null || !mounted) return;

    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!mounted) return;
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Camera permission is required to capture payment proof.',
            ),
            action: status.isPermanentlyDenied
                ? SnackBarAction(label: 'Settings', onPressed: openAppSettings)
                : null,
          ),
        );
        return;
      }
    }

    setState(() => _pickingProof = true);
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (image == null || !mounted) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      if (bytes.length > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please choose an image smaller than 5 MB.'),
          ),
        );
        return;
      }
      setState(() {
        _proofBytes = bytes;
        _proofName = image.name;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not add payment proof. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _pickingProof = false);
    }
  }

  void _showPaymentProof() {
    final bytes = _proofBytes;
    if (bytes == null) return;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5,
                  child: Center(
                    child: Image.memory(bytes, fit: BoxFit.contain),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  tooltip: 'Close preview',
                  onPressed: () => Navigator.pop(dialogContext),
                  icon: const Icon(Icons.close_rounded, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: Scaffold(
        backgroundColor: AppColors.deliveryBackground,
        body: SafeArea(
          child: Column(
            children: [
              DeliveryTopBar(
                title: 'Create Collection',
                subtitle: 'Record a customer payment',
                leadingIcon: Icons.arrow_back_rounded,
                onLeadingTap: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                12,
                                16,
                                20,
                              ),
                              child: _body(),
                            ),
                          ),
                          _Footer(
                            pendingAmount: _remainingAmount,
                            busy: _submitting,
                            onCancel: () => Navigator.of(context).maybePop(),
                            onSubmit: _recordCollection,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_loadingCustomers) {
      return const SizedBox(
        height: 280,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.6)),
      );
    }
    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _loadCustomers);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('Customer *'),
              const SizedBox(height: 8),
              FormField<_PaymentCustomer>(
                initialValue: _selectedCustomer,
                validator: (v) => v == null ? 'Please select customer' : null,
                builder: (field) => InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: _loadingDetail || _submitting
                      ? null
                      : () async {
                          final customer = await showDialog<CustomerModel>(
                            context: context,
                            builder: (_) => CustomerSearchDialog(
                              customers: _customers
                                  .where(
                                    (customer) =>
                                        (customer.outstanding ?? 0) > 0,
                                  )
                                  .toList(),
                              selectedCustomerId: _selectedCustomer?.id
                                  .toString(),
                              showOutstandingAmount: true,
                              emptyMessage:
                                  'No customers have pending payments.',
                              onCreateCustomer: () =>
                                  Navigator.of(context).push<CustomerModel>(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const CreateDeliveryCustomerScreen(),
                                    ),
                                  ),
                              onViewLocation: _openCustomerModelMap,
                            ),
                          );
                          if (!mounted || customer == null) return;
                          if (!_customers.any((c) => c.id == customer.id)) {
                            _customers = [..._customers, customer];
                          }
                          final selected = _PaymentCustomer.fromModel(customer);
                          field.didChange(selected);
                          await _selectCustomer(selected);
                        },
                  child: InputDecorator(
                    decoration: _decoration().copyWith(
                      errorText: field.errorText,
                      prefixIcon: const Icon(
                        Icons.storefront_outlined,
                        size: 20,
                      ),
                      suffixIcon: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                      ),
                    ),
                    child: Text(
                      _selectedCustomer?.name ?? 'Select customer',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              if (_selectedCustomer?.address != null) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      tooltip: _selectedCustomer!.hasLocation
                          ? 'View location and directions'
                          : 'Location coordinates unavailable',
                      onPressed: _selectedCustomer!.hasLocation
                          ? _openCustomerMap
                          : null,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: AppColors.deliveryGreen,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _selectedCustomer!.address!,
                        style: const TextStyle(
                          color: Color(0xFF7C8491),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payment Details',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              const _Label('Amount Due'),
              const SizedBox(height: 4),
              _loadingDetail
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _formatMoney(_amountDue),
                      style: const TextStyle(
                        color: Color(0xFFD93838),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
              const SizedBox(height: 20),
              const _Label('Payment Mode'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _paymentMode,
                isExpanded: true,
                decoration: _decoration(),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'upi', child: Text('UPI')),
                  DropdownMenuItem(
                    value: 'bank_transfer',
                    child: Text('Bank Transfer'),
                  ),
                  DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                  DropdownMenuItem(value: 'card', child: Text('Card')),
                ],
                onChanged: (v) => setState(() => _paymentMode = v ?? 'cash'),
              ),
              const SizedBox(height: 16),
              const _Label('Pay Amount'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                enabled: _selectedCustomer != null && !_loadingDetail,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _decoration(hintText: '0'),
                validator: (value) {
                  final amount = double.tryParse((value ?? '').trim());
                  if (_selectedCustomer == null) {
                    return 'Please select customer';
                  }
                  if (amount == null || amount <= 0) {
                    return 'Enter amount';
                  }
                  if (amount > _amountDue) {
                    return 'Amount cannot be more than pending amount';
                  }
                  return null;
                },
              ),
              if (_paymentMode != 'cash') ...[
                const SizedBox(height: 16),
                const _Label('Reference (optional)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _referenceController,
                  decoration: _decoration(hintText: 'Transaction reference'),
                  validator: (value) {
                    if (_paymentMode != 'cash' &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Transaction reference is required';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MetaValue(
                      label: 'Collected By',
                      value: _collectorName,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MetaValue(
                      label: 'Collected Date',
                      value: _todayLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _Label('Notes'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                minLines: 3,
                maxLines: 4,
                inputFormatters: [LengthLimitingTextInputFormatter(500)],
                decoration: _decoration(hintText: 'Add a note (optional)'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: _proofBytes == null
              ? OutlinedButton.icon(
                  onPressed: _pickingProof ? null : _choosePaymentProof,
                  icon: _pickingProof
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.attach_file_rounded, size: 18),
                  label: Text(
                    _pickingProof ? 'Adding proof...' : 'Proof Attachment',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF30343B),
                    minimumSize: const Size(168, 48),
                    side: const BorderSide(color: Color(0xFFC9CED6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )
              : _ProofPreview(
                  bytes: _proofBytes!,
                  fileName: _proofName ?? 'Payment proof',
                  onPreview: _showPaymentProof,
                  onReplace: _choosePaymentProof,
                  onRemove: () => setState(() {
                    _proofBytes = null;
                    _proofName = null;
                  }),
                ),
        ),
      ],
    );
  }

  String get _collectorName {
    final provider = ApiProviderScope.of(context);
    final name = (provider.currentUser ?? provider.authMe?.user)?.name.trim();
    return name == null || name.isEmpty ? 'Delivery' : name;
  }

  String get _todayLabel {
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
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}';
  }

  InputDecoration _decoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF9AA3AF),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: const Color(0xFFFBFCFE),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: _border(const Color(0xFFE1E6EE)),
      enabledBorder: _border(const Color(0xFFE1E6EE)),
      focusedBorder: _border(AppColors.deliveryGreen, width: 1.2),
      errorBorder: _border(const Color(0xFFDC2626)),
      focusedErrorBorder: _border(const Color(0xFFDC2626), width: 1.2),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.pendingAmount,
    required this.busy,
    required this.onCancel,
    required this.onSubmit,
  });
  final double pendingAmount;
  final bool busy;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pending Amount',
                  style: TextStyle(
                    color: Color(0xFFD44A4A),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatMoney(pendingAmount),
                  style: const TextStyle(
                    color: Color(0xFFD93838),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: busy ? null : onCancel,
            style: TextButton.styleFrom(
              minimumSize: const Size(76, 48),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              foregroundColor: const Color(0xFF172033),
              backgroundColor: const Color(0xFFF4F5F7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: busy ? null : onSubmit,
            style: FilledButton.styleFrom(
              minimumSize: const Size(132, 48),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              backgroundColor: const Color(0xFF064B08),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF9AB99B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Record Collection',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7EAEF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F24352A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MetaValue extends StatelessWidget {
  const _MetaValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF4B515B), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF15191F),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ProofPreview extends StatelessWidget {
  const _ProofPreview({
    required this.bytes,
    required this.fileName,
    required this.onPreview,
    required this.onReplace,
    required this.onRemove,
  });

  final Uint8List bytes;
  final String fileName;
  final VoidCallback onPreview;
  final VoidCallback onReplace;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: 'Open payment proof preview',
          child: SizedBox(
            width: 156,
            height: 132,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Material(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFD4DAE2)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: onPreview,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.memory(
                          bytes,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Material(
                    color: const Color(0xFF6D6D6D),
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onReplace,
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.edit_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF7C8491),
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Color(0xFFD93838),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF344054),
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: Color(0xFF64748B),
              size: 52,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentCustomer {
  const _PaymentCustomer({
    required this.id,
    required this.name,
    required this.pendingAmount,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.raw,
  });
  final dynamic id;
  final String name;
  final double pendingAmount;
  final String? address;
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic> raw;

  bool get hasLocation => latitude != null && longitude != null;

  @override
  bool operator ==(Object other) {
    return other is _PaymentCustomer && other.id.toString() == id.toString();
  }

  @override
  int get hashCode => id.toString().hashCode;

  factory _PaymentCustomer.fromModel(
    CustomerModel customer, {
    _PaymentCustomer? fallback,
  }) {
    return _PaymentCustomer(
      id: customer.id,
      name: customer.name.trim().isNotEmpty
          ? customer.name
          : 'Unnamed Customer',
      pendingAmount: (customer.outstanding ?? 0).toDouble(),
      address: _customerAddress(customer),
      latitude: customer.mapLatitude ?? fallback?.latitude,
      longitude: customer.mapLongitude ?? fallback?.longitude,
      raw: const {},
    );
  }
}

String? _customerAddress(CustomerModel customer) {
  final direct =
      (customer.deliveryAddress ?? customer.billingAddress ?? customer.address)
          ?.trim();
  if (direct != null && direct.isNotEmpty) return direct;
  final parts = [customer.city, customer.state, customer.pinCode]
      .whereType<String>()
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList();
  return parts.isEmpty ? null : parts.join(', ');
}

String _apiDate(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

String _plainAmount(double value) {
  if (value == value.roundToDouble()) return value.round().toString();
  return value.toStringAsFixed(2);
}

String _formatMoney(double value) {
  final rounded = value.round();
  final source = rounded.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < source.length; i++) {
    final remaining = source.length - i;
    buffer.write(source[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
  }
  return (rounded < 0 ? '-Rs ' : 'Rs ') + buffer.toString();
}
