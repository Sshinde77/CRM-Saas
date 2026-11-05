import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

// Preferred Indian locale IDs in priority order.
const _kIndianLocaleIds = [
  'en-IN', // English (India) – handles Hinglish best
  'hi-IN', // Hindi
  'gu-IN', // Gujarati
  'mr-IN', // Marathi
  'ta-IN', // Tamil
  'te-IN', // Telugu
  'kn-IN', // Kannada
  'bn-IN', // Bengali
  'pa-IN', // Punjabi
  'ml-IN', // Malayalam
  'ur-IN', // Urdu
  'or-IN', // Odia
];

enum VoiceInputUseCase {
  /// Short query: customer name, phone, ID. Stops sooner (3 s pause).
  search,

  /// Long-form field entry: name, mobile, city, pincode, etc. (7 s pause).
  formFill,
}

class VoiceInputSheet extends StatefulWidget {
  const VoiceInputSheet({
    super.key,
    this.useCase = VoiceInputUseCase.formFill,
    this.title,
    this.instruction,
    this.hintText =
        'Your transcript will appear here. You can edit it before submitting.',
    this.actionLabel,
    this.minimumLength,
    this.initialText,
  });

  final VoiceInputUseCase useCase;

  /// Override title. Defaults depend on [useCase].
  final String? title;

  /// Override instruction. Defaults depend on [useCase].
  final String? instruction;

  final String hintText;

  /// Override action button label. Defaults depend on [useCase].
  final String? actionLabel;

  /// Minimum transcript length before the action button is enabled.
  final int? minimumLength;

  final String? initialText;

  String get _resolvedTitle =>
      title ??
      switch (useCase) {
        VoiceInputUseCase.search => 'Voice search',
        VoiceInputUseCase.formFill => 'Voice entry',
      };

  String get _resolvedInstruction =>
      instruction ??
      switch (useCase) {
        VoiceInputUseCase.search =>
          'Say the name or phone number clearly.\n'
              'English or Hindi (Hinglish) both work.',
        VoiceInputUseCase.formFill =>
          'Say field name then value, e.g.:\n'
              '"Shop name Sharma Traders, mobile 9876543210, city Bangalore, pincode 560034".',
      };

  String get _resolvedActionLabel =>
      actionLabel ??
      switch (useCase) {
        VoiceInputUseCase.search => 'Search',
        VoiceInputUseCase.formFill => 'Extract',
      };

  int get _resolvedMinimumLength =>
      minimumLength ??
      switch (useCase) {
        VoiceInputUseCase.search => 2,
        VoiceInputUseCase.formFill => 8,
      };

  Duration get _pauseFor => switch (useCase) {
    VoiceInputUseCase.search => const Duration(seconds: 3),
    VoiceInputUseCase.formFill => const Duration(seconds: 7),
  };

  @override
  State<VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends State<VoiceInputSheet>
    with SingleTickerProviderStateMixin {
  final _speech = SpeechToText();
  final _transcriptController = TextEditingController();
  late final AnimationController _pulseController;

  bool _speechReady = false;
  bool _initializing = true;
  bool _starting = false;
  bool _listening = false;
  String? _error;
  List<LocaleName> _locales = const [];
  String? _selectedLocaleId;

  // Text saved before the current recording session begins, so each
  // new session appends rather than replacing the full transcript.
  String _priorText = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.92,
      upperBound: 1.08,
    );
    _transcriptController.text = widget.initialText ?? '';
    _priorText = widget.initialText ?? '';
    _initializeSpeech();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _transcriptController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
    final micPerm = await Permission.microphone.request();
    final speechPerm = defaultTargetPlatform == TargetPlatform.iOS
        ? await Permission.speech.request()
        : PermissionStatus.granted;
    if (!micPerm.isGranted || !speechPerm.isGranted) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error =
            'Microphone and speech recognition permissions are required for voice entry.';
      });
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        final isListening = status == 'listening';
        setState(() => _listening = isListening);
        if (isListening) {
          _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _listening = false;
          _error = error.errorMsg.isEmpty
              ? 'Speech recognition failed. Please try again.'
              : error.errorMsg;
        });
        _pulseController.stop();
      },
    );

    final rawLocales = available ? await _speech.locales() : <LocaleName>[];
    final systemLocale = available ? await _speech.systemLocale() : null;
    if (!mounted) return;

    final sortedLocales = _sortLocalesForIndia(rawLocales);
    final bestLocaleId = _pickBestLocale(sortedLocales, systemLocale);

    setState(() {
      _speechReady = available;
      _locales = sortedLocales;
      _selectedLocaleId = bestLocaleId;
      _initializing = false;
      _error = available
          ? null
          : 'Speech recognition is unavailable on this device.';
    });
  }

  /// Returns locales with Indian languages at the top (en-IN first, hi-IN
  /// second, then other *-IN locales, then everything else sorted by name).
  List<LocaleName> _sortLocalesForIndia(List<LocaleName> locales) {
    final top = <LocaleName>[];
    final otherIndian = <LocaleName>[];
    final rest = <LocaleName>[];

    for (final l in locales) {
      final id = l.localeId;
      if (_kIndianLocaleIds.contains(id)) {
        top.add(l);
      } else if (id.endsWith('-IN') || id.endsWith('_IN')) {
        otherIndian.add(l);
      } else {
        rest.add(l);
      }
    }

    top.sort((a, b) {
      final ia = _kIndianLocaleIds.indexOf(a.localeId);
      final ib = _kIndianLocaleIds.indexOf(b.localeId);
      return ia.compareTo(ib);
    });
    otherIndian.sort((a, b) => a.name.compareTo(b.name));
    rest.sort((a, b) => a.name.compareTo(b.name));
    return [...top, ...otherIndian, ...rest];
  }

  /// Picks en-IN first (best for Hinglish), then hi-IN, then any *-IN locale,
  /// then system locale, then first available.
  String? _pickBestLocale(List<LocaleName> locales, LocaleName? systemLocale) {
    for (final id in ['en-IN', 'hi-IN']) {
      if (locales.any((l) => l.localeId == id)) return id;
    }
    final anyIndian = locales.firstWhere(
      (l) => l.localeId.endsWith('-IN') || l.localeId.endsWith('_IN'),
      orElse: () => locales.isEmpty ? locales.first : LocaleName('', ''),
    );
    if (anyIndian.localeId.isNotEmpty) return anyIndian.localeId;
    return systemLocale?.localeId ??
        (locales.isEmpty ? null : locales.first.localeId);
  }

  Future<void> _startListening() async {
    if (_initializing || !_speechReady || _starting || _listening) return;
    _starting = true;
    // Save whatever the user has typed/spoken so far; new speech appends to it.
    _priorText = _transcriptController.text.trim();
    setState(() => _error = null);
    try {
      await _speech.listen(
        onResult: _onSpeechResult,
        listenOptions: SpeechListenOptions(
          localeId: _selectedLocaleId,
          partialResults: true,
          cancelOnError: false,
          listenMode: ListenMode.dictation,
          listenFor: const Duration(minutes: 2),
          pauseFor: widget._pauseFor,
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _listening = false;
          _error = 'Could not start the microphone. Please try again.';
        });
      }
    } finally {
      _starting = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _stopListening() async {
    if (!_speechReady) return;
    await _speech.stop();
    if (mounted) setState(() => _listening = false);
  }

  Future<void> _toggleListening() async {
    if (_listening || _starting) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    // Append new words to whatever was in the box before this session.
    final newWords = result.recognizedWords;
    final combined = _priorText.isEmpty ? newWords : '$_priorText $newWords';
    _transcriptController.text = combined.trim();
    _transcriptController.selection = TextSelection.collapsed(
      offset: _transcriptController.text.length,
    );
    if (mounted) setState(() {});
  }

  void _clearTranscript() {
    _transcriptController.clear();
    _priorText = '';
    setState(() {});
  }

  Future<void> _useTranscript() async {
    await _stopListening();
    final transcript = _transcriptController.text.trim();
    if (!mounted) return;
    if (transcript.length < widget._resolvedMinimumLength) {
      setState(
        () => _error = "Didn't catch that. Please tap the mic and try again.",
      );
      return;
    }
    Navigator.of(context).pop(transcript);
  }

  String get _statusText {
    if (_initializing) return 'Preparing speech recognition…';
    if (_listening) return 'Listening… tap the mic to stop.';
    final hasText = _transcriptController.text.trim().isNotEmpty;
    if (hasText) {
      return 'Tap the mic to continue speaking — it will append to what you said.';
    }
    return 'Tap the mic and speak clearly in the selected language.';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final canUse =
        _transcriptController.text.trim().length >=
        widget._resolvedMinimumLength;
    final micDisabled = _initializing || !_speechReady;
    final hasText = _transcriptController.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  widget._resolvedTitle,
                  style: AppTextStyles.screenHeading.copyWith(fontSize: 18),
                ),
              ),
              if (hasText)
                TextButton.icon(
                  onPressed: _clearTranscript,
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Instruction card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.deliveryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.deliveryGreen.withValues(alpha: 0.18),
              ),
            ),
            child: Text(
              widget._resolvedInstruction,
              textAlign: TextAlign.center,
              style: AppTextStyles.secondary.copyWith(
                color: AppColors.deliveryDashboardHeaderEnd,
              ),
            ),
          ),

          // Language selector — shown when multiple locales are available
          if (_locales.isNotEmpty) ...[
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _selectedLocaleId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Language',
                prefixIcon: const Icon(Icons.language_rounded, size: 20),
                filled: true,
                fillColor: AppColors.surfaceSoft,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _locales
                  .map(
                    (locale) => DropdownMenuItem<String>(
                      value: locale.localeId,
                      child: Text(
                        _localeDisplayName(locale),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _listening
                  ? null
                  : (value) => setState(() => _selectedLocaleId = value),
            ),
          ],

          const SizedBox(height: 14),

          // Mic button
          Center(
            child: ScaleTransition(
              scale: _pulseController,
              child: GestureDetector(
                onTap: micDisabled ? null : _toggleListening,
                child: Semantics(
                  button: true,
                  enabled: !micDisabled,
                  label: _listening
                      ? 'Tap to stop voice input'
                      : 'Tap to start voice input',
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: micDisabled
                          ? AppColors.textLightMuted.withValues(alpha: 0.35)
                          : _listening
                          ? AppColors.deliveryRed
                          : AppColors.deliveryGreen,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_listening
                                      ? AppColors.deliveryRed
                                      : AppColors.deliveryGreen)
                                  .withValues(alpha: micDisabled ? 0 : 0.22),
                          blurRadius: _listening ? 18 : 12,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      _listening ? Icons.mic_off_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Status line
          Text(
            _statusText,
            textAlign: TextAlign.center,
            style: AppTextStyles.secondary.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          // Error message
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: AppTextStyles.secondary.copyWith(
                color: AppColors.deliveryRed,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Editable transcript box
          TextField(
            controller: _transcriptController,
            minLines: 3,
            maxLines: 5,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: widget.hintText,
              filled: true,
              fillColor: AppColors.surfaceSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Action row
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _listening ? _stopListening : null,
                  child: const Text('Stop'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: canUse ? _useTranscript : null,
                  icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                  label: Text(widget._resolvedActionLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _localeDisplayName(LocaleName locale) {
    // Add a star marker to Indian locales so users can spot them quickly.
    if (_kIndianLocaleIds.contains(locale.localeId) ||
        locale.localeId.endsWith('-IN') ||
        locale.localeId.endsWith('_IN')) {
      return '★ ${locale.name}';
    }
    return locale.name;
  }
}
