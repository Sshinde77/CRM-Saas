import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../../../constants/app_colors.dart';
import '../../../models/customer_model.dart';
import '../../../providers/api_provider.dart';
import '../../../services/api_service.dart';
import '../../../services/voice_customer_extraction_service.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';
import '../../../widgets/delivery/voice_input_sheet.dart';
import 'customer_location_picker_screen.dart';

class CreateDeliveryCustomerScreen extends StatefulWidget {
  const CreateDeliveryCustomerScreen({
    super.key,
    this.voiceTranscriptPicker,
    this.voiceExtractionService = const VoiceCustomerExtractionService(),
  });

  final Future<String?> Function(BuildContext context)? voiceTranscriptPicker;
  final VoiceCustomerExtractionService voiceExtractionService;

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
  bool _extractingVoice = false;
  String? _type;
  String? _error;
  String? _voiceReviewMessage;
  bool _saving = false;
  PickedMapLocation? _pickedLocation;
  final Set<String> _autoFilledFields = <String>{};
  final Map<String, String> _voiceWarnings = <String, String>{};
  static const _green = AppColors.deliveryGreen;
  static const _customerTypes = [
    'General Trade',
    'Retail',
    'Wholesale',
    'Distributor',
    'Business',
    'Individual',
  ];

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

  bool _validMobile(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    return RegExp(r'^[6-9]\d{9}$').hasMatch(digits);
  }

  bool _validPincode(String? value) {
    return RegExp(r'^\d{6}$').hasMatch((value ?? '').trim());
  }

  bool _validGstin(String? value) {
    final text = (value ?? '').trim().toUpperCase().replaceAll(' ', '');
    if (text.isEmpty) return true;
    return RegExp(
      r'^\d{2}[A-Z]{5}\d{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
    ).hasMatch(text);
  }

  bool get _canCreateCustomer {
    final phoneDigits = _phone.text.replaceAll(RegExp(r'\D'), '');
    return !_saving &&
        !_pickingPhoto &&
        !_extractingVoice &&
        _shop.text.trim().isNotEmpty &&
        _contact.text.trim().isNotEmpty &&
        phoneDigits.length >= 10 &&
        phoneDigits.length <= 15 &&
        _validGstin(_gst.text) &&
        _type != null &&
        _address.text.trim().isNotEmpty &&
        _city.text.trim().isNotEmpty &&
        RegExp(r'^[1-9][0-9]{5}$').hasMatch(_pincode.text.trim()) &&
        _validateLocation(_location.text) == null;
  }

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

  Future<void> _startVoiceEntry() async {
    if (_saving || _extractingVoice) return;
    final transcript =
        await (widget.voiceTranscriptPicker?.call(context) ??
            showModalBottomSheet<String>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => const VoiceInputSheet(),
            ));
    if (!mounted || transcript == null) return;
    if (transcript.trim().length < 8) {
      _showSnack("Didn't catch that, please try again.");
      return;
    }

    setState(() {
      _extractingVoice = true;
      _error = null;
    });
    try {
      final result = await widget.voiceExtractionService.extract(
        transcript: transcript.trim(),
        customerTypes: _customerTypes,
      );
      if (!mounted) return;
      _applyVoiceExtraction(result);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Could not parse voice details. Please fill manually.');
      setState(() {
        _voiceReviewMessage =
            'Voice transcript captured, but we could not parse it clearly. Please fill the form manually.';
      });
    } finally {
      if (mounted) setState(() => _extractingVoice = false);
    }
  }

  void _applyVoiceExtraction(VoiceExtractionResult result) {
    final filled = Set<String>.from(_autoFilledFields);
    final updated = <String>{};
    final warnings = Map<String, String>.from(_voiceWarnings);

    void fillText({
      required String key,
      required TextEditingController controller,
      required ExtractedField<String> field,
      bool allowMedium = true,
      bool Function(String value)? validator,
      String? invalidMessage,
      String Function(String value)? normalize,
    }) {
      if (!field.wasSpoken) return;

      warnings.remove(key);
      final value = field.value?.trim();
      final allowedConfidence = field.isHigh || (allowMedium && field.isMedium);
      if (value == null || value.isEmpty || !allowedConfidence) {
        warnings[key] =
            "Couldn't understand this clearly, please enter manually";
        return;
      }
      final normalized = normalize == null ? value : normalize(value);
      if (validator != null && !validator(normalized)) {
        warnings[key] =
            invalidMessage ??
            "Couldn't understand this clearly, please enter manually";
        return;
      }
      controller.text = normalized;
      filled.add(key);
      updated.add(key);
    }

    fillText(key: 'shopName', controller: _shop, field: result.shopName);
    fillText(
      key: 'contactPerson',
      controller: _contact,
      field: result.contactPerson,
    );
    fillText(
      key: 'mobileNumber',
      controller: _phone,
      field: result.mobileNumber,
      allowMedium: false,
      normalize: (value) => value.replaceAll(RegExp(r'\D'), ''),
      validator: _validMobile,
      invalidMessage: 'Please enter a valid 10-digit mobile number',
    );
    fillText(
      key: 'gstin',
      controller: _gst,
      field: result.gstin,
      allowMedium: false,
      normalize: (value) => value.toUpperCase().replaceAll(' ', ''),
      validator: _validGstin,
      invalidMessage: 'Please enter a valid GSTIN',
    );
    fillText(key: 'address', controller: _address, field: result.address);
    fillText(key: 'city', controller: _city, field: result.city);
    fillText(
      key: 'pincode',
      controller: _pincode,
      field: result.pincode,
      allowMedium: false,
      normalize: (value) => value.replaceAll(RegExp(r'\D'), ''),
      validator: _validPincode,
      invalidMessage: 'Please enter a valid 6-digit pincode',
    );

    final type = _mapCustomerType(result.customerType.value);
    if (result.customerType.wasSpoken) {
      warnings.remove('customerType');
      if (type != null &&
          (result.customerType.isHigh || result.customerType.isMedium)) {
        _type = type;
        filled.add('customerType');
        updated.add('customerType');
      } else {
        warnings['customerType'] =
            "Couldn't match the customer type, please select manually";
      }
    }

    setState(() {
      _autoFilledFields
        ..clear()
        ..addAll(filled);
      _voiceWarnings
        ..clear()
        ..addAll(warnings);
      _voiceReviewMessage =
          'We updated ${updated.length} field${updated.length == 1 ? '' : 's'} from what you said. Please review before submitting.';
    });
  }

  String? _mapCustomerType(String? value) {
    final text = value?.trim().toLowerCase();
    if (text == null || text.isEmpty) return null;
    for (final type in _customerTypes) {
      if (type.toLowerCase() == text) return type;
    }
    if (text.contains('retail') || text.contains('dukaan')) return 'Retail';
    if (text.contains('whole')) return 'Wholesale';
    if (text.contains('distrib')) return 'Distributor';
    if (text.contains('business')) return 'Business';
    if (text.contains('individual')) return 'Individual';
    if (text.contains('general')) return 'General Trade';
    return null;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _validateLocation(String? value) {
    if (_pickedLocation != null && (value ?? '').trim().isNotEmpty) {
      return null;
    }
    final parts = (value ?? '').split(',');
    if (parts.length != 2) return 'Pick a location on Google Maps';
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

  latlong.LatLng? _locationFromText(String value) {
    if (_validateLocation(value) != null) return null;
    final parts = value.split(',');
    return latlong.LatLng(
      double.parse(parts[0].trim()),
      double.parse(parts[1].trim()),
    );
  }

  Future<void> _pickLocation() async {
    FocusScope.of(context).unfocus();
    final selected = await Navigator.of(context).push<PickedMapLocation>(
      MaterialPageRoute(
        builder: (_) => CustomerLocationPickerScreen(
          initialLocation:
              _pickedLocation?.location ?? _locationFromText(_location.text),
          initialPlaceName: _pickedLocation?.placeName,
        ),
      ),
    );
    if (!mounted || selected == null) return;
    setState(() {
      _pickedLocation = selected;
      _location.text = selected.placeName;
    });
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
      final mapLocation =
          _pickedLocation?.location ?? _locationFromText(_location.text);
      final locationNote = _pickedLocation == null
          ? _location.text.trim()
          : '${_pickedLocation!.placeName} (${_coordinateText(_pickedLocation!.location)})';
      final customer = await provider.createCustomer(
        request: CustomerCreateRequest(
          name: _shop.text.trim(),
          businessName: _shop.text.trim(),
          phone: _phone.text.trim(),
          gstNumber: _gst.text.trim().toUpperCase(),
          category: _type,
          billingAddress: address,
          deliveryAddress: address,
          mapLatitude: mapLocation?.latitude,
          mapLongitude: mapLocation?.longitude,
          notes:
              'Contact person: ${_contact.text.trim()}\nGeo-tag location: $locationNote'
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

  String _coordinateText(latlong.LatLng location) {
    return '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deliveryBackground,
      body: SafeArea(
        child: Column(
          children: [
            DeliveryTopBar(
              title: 'Create Customer',
              subtitle: 'Add a new delivery customer',
              leadingIcon: Icons.arrow_back_rounded,
              onLeadingTap: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
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
                                                  errorBuilder:
                                                      (
                                                        _,
                                                        error,
                                                        stack,
                                                      ) => const Icon(
                                                        Icons
                                                            .broken_image_outlined,
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
                                style: const TextStyle(
                                  color: AppColors.deliveryRed,
                                ),
                              ),
                            ),
                          _VoiceEntryCard(
                            extracting: _extractingVoice,
                            onTap: _startVoiceEntry,
                          ),
                          if (_voiceReviewMessage != null) ...[
                            const SizedBox(height: 12),
                            _VoiceReviewBanner(message: _voiceReviewMessage!),
                          ],
                          const SizedBox(height: 16),
                          _field(
                            'Shop Name',
                            _shop,
                            fieldKey: 'shopName',
                            hint: 'Enter shop name',
                            capitalization: TextCapitalization.words,
                          ),
                          _field(
                            'Contact Person',
                            _contact,
                            fieldKey: 'contactPerson',
                            hint: 'Enter contact person',
                            capitalization: TextCapitalization.words,
                          ),
                          _field(
                            'Mobile Number',
                            _phone,
                            fieldKey: 'mobileNumber',
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
                            fieldKey: 'gstin',
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
                            decoration: _decoration(
                              'Select customer type',
                              fieldKey: 'customerType',
                            ),
                            isExpanded: true,
                            items: _customerTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                            onChanged: _saving
                                ? null
                                : (value) => setState(() {
                                    _type = value;
                                    _voiceWarnings.remove('customerType');
                                  }),
                            validator: _required,
                          ),
                          _FieldAssist(
                            autoFilled: _autoFilledFields.contains(
                              'customerType',
                            ),
                            warning: _voiceWarnings['customerType'],
                          ),
                          const SizedBox(height: 18),
                          _field(
                            'Address',
                            _address,
                            fieldKey: 'address',
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
                                  fieldKey: 'city',
                                  hint: 'City',
                                  capitalization: TextCapitalization.words,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _field(
                                  'Pincode',
                                  _pincode,
                                  fieldKey: 'pincode',
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
                              helperText:
                                  'Pick on Google Maps or enter latitude, longitude',
                              suffixIcon: IconButton(
                                tooltip: 'Pick on Google Maps',
                                onPressed: _saving ? null : _pickLocation,
                                icon: const Icon(
                                  Icons.map_outlined,
                                  color: _green,
                                  size: 21,
                                ),
                              ),
                            ),
                            validator: _validateLocation,
                            onChanged: (_) => setState(() {
                              _pickedLocation = null;
                            }),
                            onFieldSubmitted: (_) => _save(),
                          ),
                          const SizedBox(height: 26),
                          FilledButton(
                            onPressed: _canCreateCustomer ? _save : null,
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
          ],
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
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.deliveryDashboardHeaderEnd,
      ),
    ),
  );

  Widget _field(
    String title,
    TextEditingController controller, {
    required String fieldKey,
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
          decoration: _decoration(hint, fieldKey: fieldKey),
          validator: validator ?? (required ? _required : null),
          onChanged: (_) {
            setState(() => _voiceWarnings.remove(fieldKey));
          },
        ),
        _FieldAssist(
          autoFilled: _autoFilledFields.contains(fieldKey),
          warning: _voiceWarnings[fieldKey],
        ),
      ],
    ),
  );

  InputDecoration _decoration(String? hint, {String? fieldKey}) {
    final hasWarning = fieldKey != null && _voiceWarnings.containsKey(fieldKey);
    final autoFilled = fieldKey != null && _autoFilledFields.contains(fieldKey);
    final borderColor = hasWarning
        ? AppColors.deliveryOrange
        : autoFilled
        ? _green
        : AppColors.border;

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textLightMuted, fontSize: 14),
      filled: true,
      fillColor: autoFilled
          ? _green.withValues(alpha: 0.08)
          : hasWarning
          ? AppColors.deliveryOrange.withValues(alpha: 0.08)
          : AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _green, width: 1.5),
      ),
    );
  }
}

class _VoiceEntryCard extends StatelessWidget {
  const _VoiceEntryCard({required this.extracting, required this.onTap});

  final bool extracting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.deliveryGreen.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.mic_rounded,
              color: AppColors.deliveryGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fill with voice',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 3),
                Text(
                  'Hold the mic and say field names first, e.g. "Shop name ABC Traders, mobile number 9876543210, city Pune, pincode 411001".',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: extracting ? null : onTap,
            icon: extracting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_fix_high_rounded, size: 18),
            label: Text(extracting ? 'Extracting' : 'Voice'),
          ),
        ],
      ),
    );
  }
}

class _VoiceReviewBanner extends StatelessWidget {
  const _VoiceReviewBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.deliveryGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.deliveryGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.fact_check_outlined,
            color: AppColors.deliveryGreen,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.deliveryDashboardHeaderEnd,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldAssist extends StatelessWidget {
  const _FieldAssist({required this.autoFilled, this.warning});

  final bool autoFilled;
  final String? warning;

  @override
  Widget build(BuildContext context) {
    if (!autoFilled && warning == null) return const SizedBox.shrink();
    final isWarning = warning != null;
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 2),
      child: Row(
        children: [
          Icon(
            isWarning ? Icons.warning_amber_rounded : Icons.mic_rounded,
            size: 14,
            color: isWarning
                ? AppColors.deliveryOrange
                : AppColors.deliveryGreen,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              warning ?? 'Auto-filled from voice',
              style: TextStyle(
                color: isWarning
                    ? AppColors.deliveryOrange
                    : AppColors.deliveryGreen,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
