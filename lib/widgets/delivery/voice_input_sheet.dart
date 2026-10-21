import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../constants/app_colors.dart';

class VoiceInputSheet extends StatefulWidget {
  const VoiceInputSheet({
    super.key,
    this.title = 'Voice customer details',
    this.instruction =
        'Speak like this: "Shop name Sharma Traders, contact person Rajesh, mobile number 9876543210, city Bangalore, pincode 560034".',
    this.hintText = 'Your transcript will appear here. You can edit it.',
    this.actionLabel = 'Extract',
    this.minimumLength = 8,
    this.initialText,
  });

  final String title;
  final String instruction;
  final String hintText;
  final String actionLabel;
  final int minimumLength;
  final String? initialText;

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
  bool _holdingMic = false;
  bool _listening = false;
  String? _error;
  List<LocaleName> _locales = const [];
  String? _selectedLocaleId;

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
    final microphonePermission = await Permission.microphone.request();
    final speechPermission = await Permission.speech.request();
    if (!microphonePermission.isGranted || !speechPermission.isGranted) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error =
            'Microphone and speech recognition permissions are needed for voice entry.';
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
          if (!_holdingMic) _speech.stop();
        } else {
          _pulseController.stop();
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _listening = false;
          _error = error.errorMsg.isEmpty
              ? 'Speech recognition failed.'
              : error.errorMsg;
        });
        _pulseController.stop();
      },
    );

    final locales = available ? await _speech.locales() : <LocaleName>[];
    final systemLocale = available ? await _speech.systemLocale() : null;
    if (!mounted) return;
    setState(() {
      _speechReady = available;
      _locales = locales;
      _selectedLocaleId =
          systemLocale?.localeId ??
          (locales.isEmpty ? null : locales.first.localeId);
      _initializing = false;
      _error = available ? null : 'Speech recognition is unavailable.';
    });
  }

  Future<void> _startHoldListening() async {
    if (_initializing || !_speechReady) return;
    _holdingMic = true;
    if (_listening) return;
    setState(() => _error = null);
    await _speech.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(
        localeId: _selectedLocaleId,
        partialResults: true,
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(minutes: 2),
      ),
    );
    if (!mounted || _holdingMic) return;
    await _speech.stop();
  }

  Future<void> _stopHoldListening() async {
    _holdingMic = false;
    if (!_speechReady) return;
    await _speech.stop();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _transcriptController.text = result.recognizedWords;
    _transcriptController.selection = TextSelection.collapsed(
      offset: _transcriptController.text.length,
    );
    if (mounted) setState(() {});
  }

  Future<void> _useTranscript() async {
    await _stopHoldListening();
    final transcript = _transcriptController.text.trim();
    if (!mounted) return;
    if (transcript.length < widget.minimumLength) {
      setState(() => _error = "Didn't catch that, please try again.");
      return;
    }
    Navigator.of(context).pop(transcript);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final canUse =
        _transcriptController.text.trim().length >= widget.minimumLength;
    final micDisabled = _initializing || !_speechReady;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.deliveryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.deliveryGreen.withValues(alpha: 0.18),
              ),
            ),
            child: Text(
              widget.instruction,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.deliveryDashboardHeaderEnd,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (_locales.isNotEmpty) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedLocaleId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Voice language',
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
                        locale.name,
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
          Center(
            child: ScaleTransition(
              scale: _pulseController,
              child: GestureDetector(
                onTapDown: micDisabled ? null : (_) => _startHoldListening(),
                onTapUp: micDisabled ? null : (_) => _stopHoldListening(),
                onTapCancel: micDisabled ? null : _stopHoldListening,
                child: Semantics(
                  button: true,
                  enabled: !micDisabled,
                  label: _listening
                      ? 'Release to stop voice input'
                      : 'Hold to start voice input',
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
          const SizedBox(height: 10),
          Text(
            _initializing
                ? 'Preparing speech recognition...'
                : _listening
                ? 'Listening... release the mic to stop.'
                : 'Hold the mic, speak in the selected language, then release.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.deliveryRed,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: _transcriptController,
            minLines: 4,
            maxLines: 6,
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _listening ? _stopHoldListening : null,
                  child: const Text('Stop'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: canUse ? _useTranscript : null,
                  icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                  label: Text(widget.actionLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
