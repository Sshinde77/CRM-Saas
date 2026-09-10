import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants/app_colors.dart';
import '../../../models/customer_model.dart';
import '../../../providers/api_provider.dart';
import '../../../services/api_service.dart';

class CreateDeliveryCustomerScreen extends StatefulWidget {
  const CreateDeliveryCustomerScreen({super.key});

  @override
  State<CreateDeliveryCustomerScreen> createState() =>
      _CreateDeliveryCustomerScreenState();
}

class _CreateDeliveryCustomerScreenState
    extends State<CreateDeliveryCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shop = TextEditingController();
  final _contact = TextEditingController();
  final _phone = TextEditingController();
  final _gst = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _pincode = TextEditingController();
  final _location = TextEditingController();
  final _locationFocus = FocusNode();
  final _imagePicker = ImagePicker();
  Uint8List? _photoBytes;
  String? _photoName;
  UploadedFileReference? _uploadedPhoto;
  bool _pickingPhoto = false;
  String? _type;
  String? _error;
  bool _saving = false;
  static const _green = AppColors.deliveryGreen;

  @override
  void dispose() {
    for (final controller in [
      _shop,
      _contact,
      _phone,
      _gst,
      _address,
      _city,
      _pincode,
      _location,
    ]) {
      controller.dispose();
    }
    _locationFocus.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  Future<void> _pickPhoto() async {
    if (_saving || _pickingPhoto) return;
    setState(() => _pickingPhoto = true);
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
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
        _photoBytes = bytes;
        _photoName = image.name;
        _uploadedPhoto = null;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the photo. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _pickingPhoto = false);
    }
  }

  String? _validateLocation(String? value) {
    final parts = (value ?? '').split(',');
    if (parts.length != 2) return 'Enter latitude, longitude';
    final latitude = double.tryParse(parts[0].trim());
    final longitude = double.tryParse(parts[1].trim());
    if (latitude == null ||
        longitude == null ||
        !latitude.isFinite ||
        !longitude.isFinite ||
        latitude.abs() > 90 ||
        longitude.abs() > 180) {
      return 'Enter valid latitude and longitude';
    }
    return null;
  }

  Future<void> _save() async {
    if (_saving || _pickingPhoto || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    final address =
        '${_address.text.trim()}, ${_city.text.trim()} - ${_pincode.text.trim()}';
    try {
      final provider = ApiProviderScope.of(context);
      if (_photoBytes != null && _uploadedPhoto == null) {
        _uploadedPhoto = await provider.uploadGenericFile(
          fileBytes: _photoBytes!,
          fileName: _photoName!,
        );
        if (!mounted) return;
      }
      final customer = await provider.createCustomer(
        request: CustomerCreateRequest(
          name: _shop.text.trim(),
          businessName: _shop.text.trim(),
          phone: _phone.text.trim(),
          gstNumber: _gst.text.trim().toUpperCase(),
          category: _type,
          billingAddress: address,
          deliveryAddress: address,
          notes:
              'Contact person: ${_contact.text.trim()}\nGeo-tag location: ${_location.text.trim()}'
              '${_uploadedPhoto == null ? '' : '\nProfile image attachment: ${_uploadedPhoto!.fileId}'}',
          otherDocumentIds: _uploadedPhoto == null
              ? null
              : [_uploadedPhoto!.fileId],
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer created successfully.')),
      );
      Navigator.of(context).pop(customer);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = switch (error) {
          ApiException(statusCode: 403) =>
            'Your account does not have permission to create customers.',
          ApiException(statusCode: 401) =>
            'Please sign in again to create a customer.',
          _ => 'Could not create customer. Please try again.',
        };
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deliveryBackground,
      appBar: AppBar(
        title: const Text(
          'Create Customer',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.deliveryDashboardHeaderEnd,
        foregroundColor: AppColors.surface,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'Profile Image (Optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.deliveryDashboardHeaderEnd,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Stack(
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: ClipOval(
                                  child: ColoredBox(
                                    color: _green.withValues(alpha: 0.1),
                                    child: _photoBytes == null
                                        ? const Icon(
                                            Icons.person_outline_rounded,
                                            size: 52,
                                            color: _green,
                                          )
                                        : Image.memory(
                                            _photoBytes!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, error, stack) =>
                                                const Icon(
                                                  Icons.broken_image_outlined,
                                                  color: _green,
                                                ),
                                          ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: IconButton.filled(
                                  tooltip: 'Choose profile image',
                                  onPressed: _saving || _pickingPhoto
                                      ? null
                                      : _pickPhoto,
                                  style: IconButton.styleFrom(
                                    backgroundColor: _green,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: _saving || _pickingPhoto
                                    ? null
                                    : _pickPhoto,
                                style: TextButton.styleFrom(
                                  foregroundColor: _green,
                                ),
                                child: Text(
                                  _pickingPhoto
                                      ? 'Opening photos…'
                                      : _photoBytes == null
                                      ? 'Add Photo'
                                      : 'Change Photo',
                                ),
                              ),
                              if (_photoBytes != null)
                                TextButton(
                                  onPressed: _saving || _pickingPhoto
                                      ? null
                                      : () => setState(() {
                                          _photoBytes = null;
                                          _photoName = null;
                                          _uploadedPhoto = null;
                                        }),
                                  child: const Text(
                                    'Remove',
                                    style: TextStyle(
                                      color: AppColors.deliveryRed,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppColors.deliveryRed),
                        ),
                      ),
                    _field(
                      'Shop Name',
                      _shop,
                      hint: 'Enter shop name',
                      capitalization: TextCapitalization.words,
                    ),
                    _field(
                      'Contact Person',
                      _contact,
                      hint: 'Enter contact person',
                      capitalization: TextCapitalization.words,
                    ),
                    _field(
                      'Mobile Number',
                      _phone,
                      hint: '+91 98765 43210',
                      keyboard: TextInputType.phone,
                      validator: (value) {
                        final digits = (value ?? '').replaceAll(
                          RegExp(r'\D'),
                          '',
                        );
                        return digits.length < 10 || digits.length > 15
                            ? 'Enter a valid mobile number'
                            : null;
                      },
                    ),
                    _field(
                      'GSTIN',
                      _gst,
                      hint: 'Enter GSTIN',
                      required: false,
                      capitalization: TextCapitalization.characters,
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) return null;
                        return RegExp(
                              r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
                            ).hasMatch(text.toUpperCase())
                            ? null
                            : 'Enter a valid 15-character GSTIN';
                      },
                    ),
                    _label('Customer Type'),
                    DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: _decoration('Select customer type'),
                      isExpanded: true,
                      items:
                          const [
                                'General Trade',
                                'Retail',
                                'Wholesale',
                                'Distributor',
                                'Business',
                                'Individual',
                              ]
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                              .toList(),
                      onChanged: _saving
                          ? null
                          : (value) => setState(() => _type = value),
                      validator: _required,
                    ),
                    const SizedBox(height: 18),
                    _field(
                      'Address',
                      _address,
                      hint: 'Shop / building, street and area',
                      lines: 3,
                      capitalization: TextCapitalization.sentences,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _field(
                            'City',
                            _city,
                            hint: 'City',
                            capitalization: TextCapitalization.words,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _field(
                            'Pincode',
                            _pincode,
                            hint: '560034',
                            keyboard: TextInputType.number,
                            formatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            validator: (value) =>
                                RegExp(
                                  r'^[1-9][0-9]{5}$',
                                ).hasMatch((value ?? '').trim())
                                ? null
                                : 'Enter a 6-digit pincode',
                          ),
                        ),
                      ],
                    ),
                    _label('Geo-tag Location'),
                    TextFormField(
                      controller: _location,
                      focusNode: _locationFocus,
                      enabled: !_saving,
                      textInputAction: TextInputAction.done,
                      decoration: _decoration('12.9352, 77.6245').copyWith(
                        helperText: 'Enter latitude, longitude',
                        suffixIcon: IconButton(
                          tooltip: 'Enter location coordinates',
                          onPressed: _saving
                              ? null
                              : _locationFocus.requestFocus,
                          icon: const Icon(
                            Icons.my_location_rounded,
                            color: _green,
                            size: 21,
                          ),
                        ),
                      ),
                      validator: _validateLocation,
                      onFieldSubmitted: (_) => _save(),
                    ),
                    const SizedBox(height: 26),
                    FilledButton(
                      onPressed: _saving || _pickingPhoto ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: AppColors.surface,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'CREATE CUSTOMER',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String title, {bool required = true}) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(text: title),
          TextSpan(
            text: required ? ' *' : ' (Optional)',
            style: TextStyle(
              color: required
                  ? AppColors.deliveryRed
                  : AppColors.textLightMuted,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.deliveryDashboardHeaderEnd,
      ),
    ),
  );

  Widget _field(
    String title,
    TextEditingController controller, {
    String? hint,
    bool required = true,
    int lines = 1,
    TextInputType? keyboard,
    String? Function(String?)? validator,
    TextCapitalization capitalization = TextCapitalization.none,
    List<TextInputFormatter>? formatters,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(title, required: required),
        TextFormField(
          controller: controller,
          enabled: !_saving,
          minLines: lines,
          maxLines: lines,
          keyboardType: keyboard,
          inputFormatters: formatters,
          textCapitalization: capitalization,
          textInputAction: TextInputAction.next,
          decoration: _decoration(hint),
          validator: validator ?? (required ? _required : null),
        ),
      ],
    ),
  );

  InputDecoration _decoration(String? hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textLightMuted, fontSize: 13),
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _green, width: 1.5),
    ),
  );
}
